const { z } = require('zod');

const coercedBoolean = z
  .union([z.boolean(), z.enum(['true', 'false'])])
  .transform((v) => v === true || v === 'true');

const createListingSchema = z.object({
  categoryId: z.string().uuid('Select a valid category'),
  farmId: z.string().uuid().optional(),
  title: z.string().trim().min(3, 'Title must be at least 3 characters').max(120),
  description: z.string().trim().max(2000).optional(),
  pricePerUnit: z.coerce.number().positive('Price must be greater than zero'),
  unit: z.string().trim().min(1).default('quintal'),
  quantityAvailable: z.coerce.number().min(0, 'Quantity cannot be negative'),
  suggestedMarketPrice: z.coerce.number().positive().optional(),
  isOrganic: coercedBoolean.optional().default(false),
  harvestDate: z.string().date().optional(),
  district: z.string().trim().optional(),
  state: z.string().trim().optional(),
  village: z.string().trim().optional(),
  status: z.enum(['draft', 'active']).optional().default('active'),
});

const updateListingSchema = createListingSchema.partial();

const searchListingsSchema = z.object({
  q: z.string().trim().optional(),
  categoryId: z.string().uuid().optional(),
  district: z.string().trim().optional(),
  state: z.string().trim().optional(),
  organic: coercedBoolean.optional(),
  minPrice: z.coerce.number().min(0).optional(),
  maxPrice: z.coerce.number().min(0).optional(),
  sortBy: z.enum(['newest', 'price_asc', 'price_desc', 'rating']).optional().default('newest'),
  page: z.coerce.number().int().min(1).optional().default(1),
  pageSize: z.coerce.number().int().min(1).max(50).optional().default(20),
});

const reportListingSchema = z.object({
  reason: z.string().trim().min(3, 'Please provide a reason').max(200),
  details: z.string().trim().max(1000).optional(),
});

module.exports = { createListingSchema, updateListingSchema, searchListingsSchema, reportListingSchema };
