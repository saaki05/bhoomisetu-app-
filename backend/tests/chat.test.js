const request = require('supertest');

jest.mock('../src/services/chat.service');

const chatService = require('../src/services/chat.service');
const createApp = require('../src/app');
const { signAccessToken } = require('../src/utils/jwt');

describe('Chat routes', () => {
  const app = createApp();
  const token = signAccessToken({ sub: 'user-1', role: 'buyer', email: 'buyer@example.com' });

  afterEach(() => jest.clearAllMocks());

  it('rejects unauthenticated requests', async () => {
    const response = await request(app).get('/api/v1/chat/conversations');
    expect(response.status).toBe(401);
  });

  describe('POST /api/v1/chat/conversations', () => {
    it('rejects an invalid otherUserId', async () => {
      const response = await request(app)
        .post('/api/v1/chat/conversations')
        .set('Authorization', `Bearer ${token}`)
        .send({ otherUserId: 'not-a-uuid' });

      expect(response.status).toBe(400);
      expect(chatService.getOrCreateConversation).not.toHaveBeenCalled();
    });

    it('starts a conversation with a valid participant', async () => {
      chatService.getOrCreateConversation.mockResolvedValue({ id: 'conversation-1' });

      const response = await request(app)
        .post('/api/v1/chat/conversations')
        .set('Authorization', `Bearer ${token}`)
        .send({ otherUserId: '11111111-1111-1111-1111-111111111111' });

      expect(response.status).toBe(201);
      expect(chatService.getOrCreateConversation).toHaveBeenCalledWith(
        'user-1',
        '11111111-1111-1111-1111-111111111111',
        undefined,
      );
    });
  });

  describe('POST /api/v1/chat/conversations/:id/messages', () => {
    it('rejects an empty message body', async () => {
      const response = await request(app)
        .post('/api/v1/chat/conversations/conversation-1/messages')
        .set('Authorization', `Bearer ${token}`)
        .send({ content: '' });

      expect(response.status).toBe(400);
      expect(chatService.sendMessage).not.toHaveBeenCalled();
    });

    it('sends a valid text message', async () => {
      chatService.sendMessage.mockResolvedValue({
        message: { id: 'message-1', content: 'Hello' },
        recipientId: 'user-2',
      });

      const response = await request(app)
        .post('/api/v1/chat/conversations/conversation-1/messages')
        .set('Authorization', `Bearer ${token}`)
        .send({ content: 'Hello' });

      expect(response.status).toBe(201);
      expect(response.body.data.content).toBe('Hello');
    });
  });

  describe('POST /api/v1/chat/conversations/:id/read', () => {
    it('marks messages as read', async () => {
      chatService.markMessagesRead.mockResolvedValue(3);

      const response = await request(app)
        .post('/api/v1/chat/conversations/conversation-1/read')
        .set('Authorization', `Bearer ${token}`);

      expect(response.status).toBe(200);
      expect(response.body.data.updatedCount).toBe(3);
    });
  });
});
