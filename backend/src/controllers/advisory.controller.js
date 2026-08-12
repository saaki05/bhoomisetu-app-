const advisoryService = require('../services/advisory.service');
const asyncHandler = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/apiResponse');

const chat = asyncHandler(async (req, res) => {
  const result = await advisoryService.sendChatMessage(req.body);
  sendSuccess(res, { data: result });
});

module.exports = { chat };
