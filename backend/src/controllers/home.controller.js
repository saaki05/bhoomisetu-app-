const homeService = require('../services/home.service');
const asyncHandler = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/apiResponse');

const summary = asyncHandler(async (req, res) => {
  const lat = req.query.lat != null ? Number(req.query.lat) : undefined;
  const lon = req.query.lon != null ? Number(req.query.lon) : undefined;
  const data = await homeService.getHomeSummary(req.user.id, {
    lat: Number.isFinite(lat) ? lat : undefined,
    lon: Number.isFinite(lon) ? lon : undefined,
  });
  sendSuccess(res, { data });
});

module.exports = { summary };
