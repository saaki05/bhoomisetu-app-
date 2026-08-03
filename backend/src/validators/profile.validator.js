const { z } = require('zod');

const optionalText = (max) => z.string().trim().max(max).optional().nullable();

const updateProfileSchema = z.object({
  fullName: z.string().trim().min(2, 'Name must be at least 2 characters').max(100).optional(),
  phone: z.string().trim().regex(/^[6-9]\d{9}$/, 'Enter a valid 10-digit Indian mobile number').optional().nullable(),
  bio: optionalText(500),
  village: optionalText(100),
  district: optionalText(100),
  state: optionalText(100),
  pincode: z.string().trim().regex(/^\d{6}$/, 'Enter a valid 6-digit PIN code').optional().nullable(),
  latitude: z.coerce.number().min(-90).max(90).optional(),
  longitude: z.coerce.number().min(-180).max(180).optional(),
}).refine(
  (value) => (value.latitude === undefined) === (value.longitude === undefined),
  { message: 'Latitude and longitude must be provided together', path: ['latitude'] },
);

module.exports = { updateProfileSchema };
