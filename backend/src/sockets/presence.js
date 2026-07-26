/**
 * In-memory online-user tracking, keyed by userId with a ref count (a user
 * can have multiple sockets open — multiple tabs/devices). Adequate for a
 * single API instance; a horizontally-scaled deployment should replace this
 * with a Redis set (e.g. via the socket.io-redis adapter) so presence is
 * shared across instances instead of being process-local.
 */
const onlineUsers = new Map();

function markOnline(userId) {
  onlineUsers.set(userId, (onlineUsers.get(userId) ?? 0) + 1);
}

function markOffline(userId) {
  const count = (onlineUsers.get(userId) ?? 1) - 1;
  if (count <= 0) {
    onlineUsers.delete(userId);
  } else {
    onlineUsers.set(userId, count);
  }
}

function isOnline(userId) {
  return onlineUsers.has(userId);
}

module.exports = { markOnline, markOffline, isOnline };
