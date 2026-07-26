const ordersService = require('../services/orders.service');
const asyncHandler = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/apiResponse');
const AppError = require('../utils/AppError');

const createOrder = asyncHandler(async (req, res) => {
  if (req.user.role !== 'buyer' && req.user.role !== 'admin') {
    throw AppError.forbidden('Only buyers can place orders', 'ROLE_NOT_ALLOWED');
  }
  const order = await ordersService.createOrder(req.user.id, req.body);
  sendSuccess(res, { statusCode: 201, message: 'Order placed successfully', data: order });
});

const listOrders = asyncHandler(async (req, res) => {
  const result = await ordersService.listOrders(req.user.id, req.query);
  sendSuccess(res, {
    data: result.items,
    meta: { page: result.page, pageSize: result.pageSize, total: result.total, totalPages: result.totalPages },
  });
});

const getOrder = asyncHandler(async (req, res) => {
  const order = await ordersService.getOrderById(req.user.id, req.user.role, req.params.id);
  sendSuccess(res, { data: order });
});

const updateOrderStatus = asyncHandler(async (req, res) => {
  const order = await ordersService.updateOrderStatus(req.user.id, req.user.role, req.params.id, req.body);
  sendSuccess(res, { message: 'Order status updated successfully', data: order });
});

const createReview = asyncHandler(async (req, res) => {
  await ordersService.createReview(req.user.id, req.params.id, req.body);
  sendSuccess(res, { statusCode: 201, message: 'Review submitted successfully' });
});

module.exports = { createOrder, listOrders, getOrder, updateOrderStatus, createReview };
