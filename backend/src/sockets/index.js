const { Server } = require('socket.io');
const { loadEnv } = require('../config/env');
const logger = require('../config/logger');
const { verifyAccessToken } = require('../utils/jwt');
const registerChatHandlers = require('./chat.socket');

const env = loadEnv();

/**
 * Initializes the shared Socket.IO server and attaches JWT-based auth.
 * Feature-specific event handlers (chat, notifications, ...) register
 * themselves against the returned `io` instance from their own modules.
 */
function initSocketServer(httpServer) {
  const io = new Server(httpServer, {
    cors: {
      // Same "*" caveat as app.js: the cors check needs boolean true to
      // actually reflect any origin, a literal "*" array entry never matches.
      origin: env.NODE_ENV === 'production' && env.CLIENT_ORIGIN !== '*' ? env.CLIENT_ORIGIN.split(',') : true,
      credentials: true,
    },
  });

  io.use((socket, next) => {
    try {
      const token = socket.handshake.auth?.token || socket.handshake.headers?.authorization?.split(' ')[1];
      if (!token) return next(new Error('Authentication token missing'));

      const payload = verifyAccessToken(token);
      socket.user = { id: payload.sub, role: payload.role, email: payload.email };
      return next();
    } catch (err) {
      return next(new Error('Authentication failed'));
    }
  });

  io.on('connection', (socket) => {
    logger.info(`Socket connected: ${socket.id} (user ${socket.user.id})`);
    socket.join(`user:${socket.user.id}`);

    registerChatHandlers(io, socket);

    socket.on('disconnect', (reason) => {
      logger.info(`Socket disconnected: ${socket.id} (${reason})`);
    });
  });

  return io;
}

module.exports = initSocketServer;
