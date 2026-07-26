const { Router } = require('express');
const controller = require('../controllers/chat.controller');
const validate = require('../middleware/validate');
const authenticate = require('../middleware/authenticate');
const { startConversationSchema, sendMessageSchema, listMessagesQuerySchema } = require('../validators/chat.validator');

const router = Router();

router.use(authenticate);

/**
 * @openapi
 * /chat/conversations:
 *   get:
 *     summary: List the current user's conversations, most recent first
 *     tags: [Chat]
 *   post:
 *     summary: Start (or fetch the existing) conversation with another user
 *     tags: [Chat]
 */
router.get('/conversations', controller.listConversations);
router.post('/conversations', validate({ body: startConversationSchema }), controller.startConversation);

/**
 * @openapi
 * /chat/conversations/{id}/messages:
 *   get:
 *     summary: Paginated message history for a conversation, newest first
 *     tags: [Chat]
 *   post:
 *     summary: Send a message (REST fallback; the app normally sends via Socket.IO)
 *     tags: [Chat]
 */
router.get('/conversations/:id/messages', validate({ query: listMessagesQuerySchema }), controller.listMessages);
router.post('/conversations/:id/messages', validate({ body: sendMessageSchema }), controller.sendMessage);

/**
 * @openapi
 * /chat/conversations/{id}/read:
 *   post:
 *     summary: Mark all of the other participant's messages as read
 *     tags: [Chat]
 */
router.post('/conversations/:id/read', controller.markRead);

module.exports = router;
