const { supabaseAdmin } = require('../config/supabase');
const AppError = require('../utils/AppError');

// Which roles may move an order into a given status, and from which
// statuses that transition is legal. Keeps the status machine explicit and
// in one place instead of scattered `if` checks.
const TRANSITIONS = {
  accepted: { allowedFrom: ['pending'], allowedRoles: ['farmer'] },
  rejected: { allowedFrom: ['pending'], allowedRoles: ['farmer'] },
  preparing: { allowedFrom: ['accepted'], allowedRoles: ['farmer'] },
  out_for_delivery: { allowedFrom: ['preparing'], allowedRoles: ['farmer'] },
  delivered: { allowedFrom: ['out_for_delivery'], allowedRoles: ['farmer'] },
  cancelled: { allowedFrom: ['pending', 'accepted'], allowedRoles: ['buyer'] },
};

const RESTOCKING_STATUSES = new Set(['rejected', 'cancelled']);

function mapOrder(row) {
  return {
    id: row.id,
    buyerId: row.buyer_id,
    farmerId: row.farmer_id,
    listingId: row.listing_id,
    listingTitle: row.crop_listings?.title,
    listingImage: row.crop_listings?.crop_listing_images?.[0]?.image_url,
    quantity: Number(row.quantity),
    unitPrice: Number(row.unit_price),
    unit: row.unit,
    totalPrice: Number(row.total_price),
    status: row.status,
    deliveryAddress: row.delivery_address,
    deliveryDistrict: row.delivery_district,
    deliveryState: row.delivery_state,
    deliveryPincode: row.delivery_pincode,
    contactPhone: row.contact_phone,
    notes: row.notes,
    buyer: row.buyer
      ? { id: row.buyer.id, fullName: row.buyer.full_name, avatarUrl: row.buyer.avatar_url, phone: row.buyer.phone }
      : undefined,
    farmer: row.farmer
      ? { id: row.farmer.id, fullName: row.farmer.full_name, avatarUrl: row.farmer.avatar_url, phone: row.farmer.phone }
      : undefined,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

const ORDER_SELECT = `
  *,
  crop_listings ( title, crop_listing_images ( image_url, display_order ) ),
  buyer:profiles!orders_buyer_id_fkey ( id, full_name, avatar_url, phone ),
  farmer:profiles!orders_farmer_id_fkey ( id, full_name, avatar_url, phone )
`;

async function createOrder(buyerId, payload) {
  const { data: listing, error: listingError } = await supabaseAdmin
    .from('crop_listings')
    .select('id, farmer_id, price_per_unit, unit, quantity_available, status')
    .eq('id', payload.listingId)
    .is('deleted_at', null)
    .single();

  if (listingError || !listing) throw AppError.notFound('Listing not found', 'LISTING_NOT_FOUND');
  if (listing.status !== 'active') {
    throw AppError.badRequest('This listing is not currently available', 'LISTING_NOT_ACTIVE');
  }
  if (listing.farmer_id === buyerId) {
    throw AppError.badRequest('You cannot order your own listing', 'CANNOT_ORDER_OWN_LISTING');
  }
  if (Number(listing.quantity_available) < payload.quantity) {
    throw AppError.badRequest('Not enough quantity available', 'INSUFFICIENT_QUANTITY');
  }

  const unitPrice = Number(listing.price_per_unit);
  const totalPrice = Math.round(unitPrice * payload.quantity * 100) / 100;

  const { data: order, error } = await supabaseAdmin
    .from('orders')
    .insert({
      buyer_id: buyerId,
      farmer_id: listing.farmer_id,
      listing_id: listing.id,
      quantity: payload.quantity,
      unit_price: unitPrice,
      unit: listing.unit,
      total_price: totalPrice,
      delivery_address: payload.deliveryAddress,
      delivery_district: payload.deliveryDistrict ?? null,
      delivery_state: payload.deliveryState ?? null,
      delivery_pincode: payload.deliveryPincode ?? null,
      contact_phone: payload.contactPhone,
      notes: payload.notes ?? null,
    })
    .select(ORDER_SELECT)
    .single();

  if (error) throw AppError.internal('Failed to create order');

  await supabaseAdmin
    .from('crop_listings')
    .update({ quantity_available: Number(listing.quantity_available) - payload.quantity })
    .eq('id', listing.id);

  await supabaseAdmin
    .from('order_status_history')
    .insert({ order_id: order.id, status: 'pending', changed_by: buyerId });

  return mapOrder(order);
}

async function listOrders(userId, filters) {
  let query = supabaseAdmin.from('orders').select(ORDER_SELECT, { count: 'exact' });

  if (filters.role === 'buyer') {
    query = query.eq('buyer_id', userId);
  } else if (filters.role === 'farmer') {
    query = query.eq('farmer_id', userId);
  } else {
    query = query.or(`buyer_id.eq.${userId},farmer_id.eq.${userId}`);
  }

  if (filters.status) query = query.eq('status', filters.status);

  query = query.order('created_at', { ascending: false });

  const from = (filters.page - 1) * filters.pageSize;
  const to = from + filters.pageSize - 1;
  query = query.range(from, to);

  const { data, error, count } = await query;
  if (error) throw AppError.internal('Failed to load orders');

  return {
    items: data.map(mapOrder),
    page: filters.page,
    pageSize: filters.pageSize,
    total: count ?? 0,
    totalPages: Math.ceil((count ?? 0) / filters.pageSize),
  };
}

async function getOrderById(userId, userRole, orderId) {
  const { data, error } = await supabaseAdmin.from('orders').select(ORDER_SELECT).eq('id', orderId).single();

  if (error || !data) throw AppError.notFound('Order not found', 'ORDER_NOT_FOUND');
  if (data.buyer_id !== userId && data.farmer_id !== userId && userRole !== 'admin') {
    throw AppError.forbidden('You do not have access to this order', 'NOT_ORDER_PARTY');
  }

  const { data: history } = await supabaseAdmin
    .from('order_status_history')
    .select('status, note, created_at')
    .eq('order_id', orderId)
    .order('created_at', { ascending: true });

  // Every other field in this response comes out of mapOrder() as camelCase;
  // this table's rows don't, so map them the same way rather than leaking
  // raw snake_case column names into the API contract.
  const mappedHistory = (history ?? []).map((event) => ({
    status: event.status,
    note: event.note,
    createdAt: event.created_at,
  }));

  return { ...mapOrder(data), history: mappedHistory };
}

async function updateOrderStatus(userId, userRole, orderId, payload) {
  const { data: order, error } = await supabaseAdmin.from('orders').select('*').eq('id', orderId).single();
  if (error || !order) throw AppError.notFound('Order not found', 'ORDER_NOT_FOUND');

  const transition = TRANSITIONS[payload.status];
  if (!transition) throw AppError.badRequest('Invalid status transition', 'INVALID_STATUS');

  if (userRole !== 'admin') {
    const callerRole = order.buyer_id === userId ? 'buyer' : order.farmer_id === userId ? 'farmer' : null;
    if (!callerRole) throw AppError.forbidden('You do not have access to this order', 'NOT_ORDER_PARTY');
    if (!transition.allowedRoles.includes(callerRole)) {
      throw AppError.forbidden(`Only the ${transition.allowedRoles.join('/')} can do that`, 'ROLE_NOT_ALLOWED');
    }
  }

  if (!transition.allowedFrom.includes(order.status)) {
    throw AppError.badRequest(
      `Cannot move an order from '${order.status}' to '${payload.status}'`,
      'INVALID_STATUS_TRANSITION',
    );
  }

  const { data: updated, error: updateError } = await supabaseAdmin
    .from('orders')
    .update({ status: payload.status })
    .eq('id', orderId)
    .select(ORDER_SELECT)
    .single();

  if (updateError) throw AppError.internal('Failed to update order status');

  await supabaseAdmin.from('order_status_history').insert({
    order_id: orderId,
    status: payload.status,
    changed_by: userId,
    note: payload.note ?? null,
  });

  if (RESTOCKING_STATUSES.has(payload.status)) {
    const { data: listing } = await supabaseAdmin
      .from('crop_listings')
      .select('quantity_available')
      .eq('id', order.listing_id)
      .single();

    if (listing) {
      await supabaseAdmin
        .from('crop_listings')
        .update({ quantity_available: Number(listing.quantity_available) + Number(order.quantity) })
        .eq('id', order.listing_id);
    }
  }

  return mapOrder(updated);
}

async function createReview(userId, orderId, payload) {
  const { data: order, error } = await supabaseAdmin.from('orders').select('*').eq('id', orderId).single();
  if (error || !order) throw AppError.notFound('Order not found', 'ORDER_NOT_FOUND');
  if (order.buyer_id !== userId) {
    throw AppError.forbidden('Only the buyer can review this order', 'NOT_ORDER_BUYER');
  }
  if (order.status !== 'delivered') {
    throw AppError.badRequest('You can only review orders that have been delivered', 'ORDER_NOT_DELIVERED');
  }

  const { data: existing } = await supabaseAdmin.from('reviews').select('id').eq('order_id', orderId).maybeSingle();
  if (existing) throw AppError.conflict('You already reviewed this order', 'ALREADY_REVIEWED');

  const { error: insertError } = await supabaseAdmin.from('reviews').insert({
    order_id: orderId,
    reviewer_id: userId,
    reviewee_id: order.farmer_id,
    rating: payload.rating,
    comment: payload.comment ?? null,
  });

  if (insertError) throw AppError.internal('Failed to submit review');
}

module.exports = { createOrder, listOrders, getOrderById, updateOrderStatus, createReview };
