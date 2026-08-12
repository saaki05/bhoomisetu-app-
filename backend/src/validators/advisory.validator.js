const { z } = require('zod');

const chatMessageSchema = z.object({
  message: z.string().trim().min(1, 'Message cannot be empty').max(2000),
  // Prior turns of the same conversation, oldest first, so the model has
  // context. Capped so a runaway client can't balloon the request payload
  // (and the token bill) — the UI only needs recent context anyway.
  history: z
    .array(
      z.object({
        role: z.enum(['user', 'assistant']),
        content: z.string().trim().min(1).max(2000),
      }),
    )
    .max(20)
    .optional()
    .default([]),
});

module.exports = { chatMessageSchema };
