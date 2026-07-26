const homeService = require('../services/home.service');
const asyncHandler = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/apiResponse');

const summary = asyncHandler(async (req, res) => {
  const data = await homeService.getHomeSummary(req.user.id);
  sendSuccess(res, { data });
});

module.exports = { summary };
