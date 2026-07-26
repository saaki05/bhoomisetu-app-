const { z } = require('zod');

const startConversationSchema = z.object({
  otherUserId: z.string().uuid('Select a valid user'),
  listingId: z.string().uuid().optional(),
});

const sendMessageSchema = z.object({
  type: z.enum(['text', 'image', 'document']).default('text'),
  content: z.string().trim().min(1, 'Message cannot be empty').max(4000),
});

const listMessagesQuerySchema = z.object({
  page: z.coerce.number().int().min(1).optional().default(1),
  pageSize: z.coerce.number().int().min(1).max(100).optional().default(30),
});

module.exports = { startConversationSchema, sendMessageSchema, listMessagesQuerySchema };
