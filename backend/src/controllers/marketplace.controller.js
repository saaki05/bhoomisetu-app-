const marketplaceService = require('../services/marketplace.service');
const asyncHandler = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/apiResponse');
const AppError = require('../utils/AppError');

const listCategories = asyncHandler(async (req, res) => {
  const categories = await marketplaceService.listCategories();
  sendSuccess(res, { data: categories });
});

const searchListings = asyncHandler(async (req, res) => {
  const result = await marketplaceService.searchListings(req.query);
  sendSuccess(res, {
    data: result.items,
    meta: { page: result.page, pageSize: result.pageSize, total: result.total, totalPages: result.totalPages },
  });
});

const getListing = asyncHandler(async (req, res) => {
  const listing = await marketplaceService.getListingById(req.params.id);
  sendSuccess(res, { data: listing });
});

const createListing = asyncHandler(async (req, res) => {
  const listing = await marketplaceService.createListing(req.user.id, req.body);
  sendSuccess(res, { statusCode: 201, message: 'Listing created successfully', data: listing });
});

const updateListing = asyncHandler(async (req, res) => {
  const listing = await marketplaceService.updateListing(req.user.id, req.params.id, req.body);
  sendSuccess(res, { message: 'Listing updated successfully', data: listing });
});

const deleteListing = asyncHandler(async (req, res) => {
  await marketplaceService.deleteListing(req.user.id, req.params.id);
  sendSuccess(res, { message: 'Listing deleted successfully' });
});

const uploadImages = asyncHandler(async (req, res) => {
  if (!req.files || req.files.length === 0) {
    throw AppError.badRequest('At least one image is required', 'NO_IMAGES_PROVIDED');
  }
  const images = await marketplaceService.addListingImages(req.user.id, req.params.id, req.files);
  sendSuccess(res, { statusCode: 201, message: 'Images uploaded successfully', data: { images } });
});

const uploadVideo = asyncHandler(async (req, res) => {
  if (!req.file) throw AppError.badRequest('A video is required', 'NO_VIDEO_PROVIDED');
  const videoUrl = await marketplaceService.addListingVideo(req.user.id, req.params.id, req.file);
  sendSuccess(res, { statusCode: 201, message: 'Video uploaded successfully', data: { videoUrl } });
});

const reportListing = asyncHandler(async (req, res) => {
  await marketplaceService.reportListing(req.user.id, req.params.id, req.body);
  sendSuccess(res, { statusCode: 201, message: 'Listing reported. Our team will review it shortly.' });
});

const toggleBookmark = asyncHandler(async (req, res) => {
  const result = await marketplaceService.toggleBookmark(req.user.id, req.params.id);
  sendSuccess(res, { data: result });
});

const listBookmarks = asyncHandler(async (req, res) => {
  const listings = await marketplaceService.listBookmarks(req.user.id);
  sendSuccess(res, { data: listings });
});

module.exports = {
  listCategories,
  searchListings,
  getListing,
  createListing,
  updateListing,
  deleteListing,
  uploadImages,
  uploadVideo,
  reportListing,
  toggleBookmark,
  listBookmarks,
};
