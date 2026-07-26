const { z } = require('zod');

const createOrderSchema = z.object({
  listingId: z.string().uuid('Select a valid listing'),
  quantity: z.coerce.number().positive('Quantity must be greater than zero'),
  deliveryAddress: z.string().trim().min(3, 'Delivery address is required'),
  deliveryDistrict: z.string().trim().optional(),
  deliveryState: z.string().trim().optional(),
  deliveryPincode: z.string().trim().optional(),
  contactPhone: z.string().trim().regex(/^[6-9]\d{9}$/, 'Enter a valid 10-digit mobile number'),
  notes: z.string().trim().max(500).optional(),
});

const updateOrderStatusSchema = z.object({
  status: z.enum([
    'accepted',
    'rejected',
    'preparing',
    'out_for_delivery',
    'delivered',
    'cancelled',
  ]),
  note: z.string().trim().max(500).optional(),
});

const listOrdersQuerySchema = z.object({
  role: z.enum(['buyer', 'farmer']).optional(),
  status: z
    .enum(['pending', 'accepted', 'rejected', 'preparing', 'out_for_delivery', 'delivered', 'cancelled', 'refunded'])
    .optional(),
  page: z.coerce.number().int().min(1).optional().default(1),
  pageSize: z.coerce.number().int().min(1).max(50).optional().default(20),
});

const createReviewSchema = z.object({
  rating: z.coerce.number().int().min(1).max(5),
  comment: z.string().trim().max(1000).optional(),
});

module.exports = { createOrderSchema, updateOrderStatusSchema, listOrdersQuerySchema, createReviewSchema };
