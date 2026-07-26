const chatService = require('../services/chat.service');
const logger = require('../config/logger');
const { markOnline, markOffline, isOnline } = require('./presence');

/**
 * Registers chat event handlers on a connected socket. Messages are
 * persisted through the same service the REST fallback uses, then pushed
 * to both participants' `user:<id>` rooms so every open tab/device for
 * that user receives it — including the sender's other sessions.
 */
function registerChatHandlers(io, socket) {
  const userId = socket.user.id;

  markOnline(userId);
  socket.broadcast.emit('presence:update', { userId, isOnline: true });

  socket.on('chat:send', async ({ conversationId, type = 'text', content }, ack) => {
    try {
      const { message, recipientId } = await chatService.sendMessage(conversationId, userId, { type, content });
      io.to(`user:${userId}`).to(`user:${recipientId}`).emit('chat:message', message);
      ack?.({ success: true, message });
    } catch (err) {
      logger.warn('chat:send failed', { error: err.message, userId, conversationId });
      ack?.({ success: false, error: err.message });
    }
  });

  socket.on('chat:typing', async ({ conversationId, isTyping }) => {
    try {
      const conversation = await chatService.assertParticipant(conversationId, userId);
      const recipientId = conversation.participant_one_id === userId
        ? conversation.participant_two_id
        : conversation.participant_one_id;
      io.to(`user:${recipientId}`).emit('chat:typing', { conversationId, userId, isTyping });
    } catch (err) {
      logger.warn('chat:typing failed', { error: err.message, userId, conversationId });
    }
  });

  socket.on('chat:read', async ({ conversationId }, ack) => {
    try {
      const conversation = await chatService.assertParticipant(conversationId, userId);
      await chatService.markMessagesRead(conversationId, userId);
      const recipientId = conversation.participant_one_id === userId
        ? conversation.participant_two_id
        : conversation.participant_one_id;
      io.to(`user:${recipientId}`).emit('chat:read', { conversationId, readBy: userId });
      ack?.({ success: true });
    } catch (err) {
      logger.warn('chat:read failed', { error: err.message, userId, conversationId });
      ack?.({ success: false, error: err.message });
    }
  });

  socket.on('presence:query', (userIds, ack) => {
    ack?.(Object.fromEntries((userIds ?? []).map((id) => [id, isOnline(id)])));
  });

  socket.on('disconnect', () => {
    markOffline(userId);
    if (!isOnline(userId)) {
      socket.broadcast.emit('presence:update', { userId, isOnline: false });
    }
  });
}

module.exports = registerChatHandlers;
