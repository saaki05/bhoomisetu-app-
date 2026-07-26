const chatService = require('../services/chat.service');
const asyncHandler = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/apiResponse');

const listConversations = asyncHandler(async (req, res) => {
  const conversations = await chatService.listConversations(req.user.id);
  sendSuccess(res, { data: conversations });
});

const startConversation = asyncHandler(async (req, res) => {
  const conversation = await chatService.getOrCreateConversation(
    req.user.id,
    req.body.otherUserId,
    req.body.listingId,
  );
  sendSuccess(res, { statusCode: 201, data: conversation });
});

const listMessages = asyncHandler(async (req, res) => {
  const result = await chatService.listMessages(req.params.id, req.user.id, req.query);
  sendSuccess(res, {
    data: result.items,
    meta: { page: result.page, pageSize: result.pageSize, total: result.total, totalPages: result.totalPages },
  });
});

const sendMessage = asyncHandler(async (req, res) => {
  const { message } = await chatService.sendMessage(req.params.id, req.user.id, req.body);
  sendSuccess(res, { statusCode: 201, data: message });
});

const markRead = asyncHandler(async (req, res) => {
  const updatedCount = await chatService.markMessagesRead(req.params.id, req.user.id);
  sendSuccess(res, { data: { updatedCount } });
});

module.exports = { listConversations, startConversation, listMessages, sendMessage, markRead };
