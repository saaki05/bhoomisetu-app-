const { Router } = require('express');
const controller = require('../controllers/marketplace.controller');
const validate = require('../middleware/validate');
const authenticate = require('../middleware/authenticate');
const authorize = require('../middleware/authorize');
const upload = require('../middleware/upload');
const {
  createListingSchema,
  updateListingSchema,
  searchListingsSchema,
  reportListingSchema,
} = require('../validators/marketplace.validator');

const router = Router();

/**
 * @openapi
 * /marketplace/categories:
 *   get:
 *     summary: List active crop categories
 *     tags: [Marketplace]
 *     security: []
 */
router.get('/categories', controller.listCategories);

/**
 * @openapi
 * /marketplace/listings:
 *   get:
 *     summary: Search/browse active crop listings with filters and pagination
 *     tags: [Marketplace]
 *     security: []
 *   post:
 *     summary: Create a new crop listing (farmers only)
 *     tags: [Marketplace]
 */
router.get('/listings', validate({ query: searchListingsSchema }), controller.searchListings);
router.post(
  '/listings',
  authenticate,
  authorize('farmer', 'admin'),
  validate({ body: createListingSchema }),
  controller.createListing,
);

/**
 * @openapi
 * /marketplace/bookmarks:
 *   get:
 *     summary: List the current user's bookmarked listings
 *     tags: [Marketplace]
 */
router.get('/bookmarks', authenticate, controller.listBookmarks);

/**
 * @openapi
 * /marketplace/listings/{id}:
 *   get:
 *     summary: Get a single crop listing
 *     tags: [Marketplace]
 *     security: []
 *   put:
 *     summary: Update a crop listing (owner only)
 *     tags: [Marketplace]
 *   delete:
 *     summary: Soft-delete a crop listing (owner only)
 *     tags: [Marketplace]
 */
router.get('/listings/:id', controller.getListing);
router.put(
  '/listings/:id',
  authenticate,
  authorize('farmer', 'admin'),
  validate({ body: updateListingSchema }),
  controller.updateListing,
);
router.delete('/listings/:id', authenticate, authorize('farmer', 'admin'), controller.deleteListing);

/**
 * @openapi
 * /marketplace/listings/{id}/images:
 *   post:
 *     summary: Upload images for a crop listing (owner only, max 6 total)
 *     tags: [Marketplace]
 */
router.post(
  '/listings/:id/images',
  authenticate,
  authorize('farmer', 'admin'),
  upload.images.array('images', 6),
  controller.uploadImages,
);

router.post(
  '/listings/:id/video',
  authenticate,
  authorize('farmer', 'admin'),
  upload.video.single('video'),
  controller.uploadVideo,
);

/**
 * @openapi
 * /marketplace/listings/{id}/report:
 *   post:
 *     summary: Report a listing for review
 *     tags: [Marketplace]
 */
router.post(
  '/listings/:id/report',
  authenticate,
  validate({ body: reportListingSchema }),
  controller.reportListing,
);

/**
 * @openapi
 * /marketplace/listings/{id}/bookmark:
 *   post:
 *     summary: Toggle a bookmark on a listing
 *     tags: [Marketplace]
 */
router.post('/listings/:id/bookmark', authenticate, controller.toggleBookmark);

module.exports = router;
