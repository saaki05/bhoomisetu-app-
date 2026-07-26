const { supabaseAdmin } = require('../config/supabase');
const AppError = require('../utils/AppError');

function orderedPair(userIdA, userIdB) {
  return userIdA < userIdB ? [userIdA, userIdB] : [userIdB, userIdA];
}

function mapParticipant(row) {
  if (!row) return undefined;
  return { id: row.id, fullName: row.full_name, avatarUrl: row.avatar_url };
}

function mapMessage(row) {
  return {
    id: row.id,
    conversationId: row.conversation_id,
    senderId: row.sender_id,
    type: row.type,
    content: row.content,
    readAt: row.read_at,
    createdAt: row.created_at,
  };
}

async function getOrCreateConversation(userId, otherUserId, listingId) {
  if (userId === otherUserId) {
    throw AppError.badRequest('You cannot start a conversation with yourself', 'INVALID_PARTICIPANT');
  }

  const [participantOne, participantTwo] = orderedPair(userId, otherUserId);

  let query = supabaseAdmin
    .from('conversations')
    .select('*, one:profiles!conversations_participant_one_id_fkey ( id, full_name, avatar_url ), two:profiles!conversations_participant_two_id_fkey ( id, full_name, avatar_url )')
    .eq('participant_one_id', participantOne)
    .eq('participant_two_id', participantTwo);

  query = listingId ? query.eq('listing_id', listingId) : query.is('listing_id', null);

  const { data: existing } = await query.maybeSingle();
  if (existing) return mapConversation(existing, userId);

  const { data: created, error } = await supabaseAdmin
    .from('conversations')
    .insert({ participant_one_id: participantOne, participant_two_id: participantTwo, listing_id: listingId ?? null })
    .select('*, one:profiles!conversations_participant_one_id_fkey ( id, full_name, avatar_url ), two:profiles!conversations_participant_two_id_fkey ( id, full_name, avatar_url )')
    .single();

  if (error) throw AppError.internal('Failed to start conversation');
  return mapConversation(created, userId);
}

function mapConversation(row, currentUserId) {
  const other = row.participant_one_id === currentUserId ? row.two : row.one;
  return {
    id: row.id,
    otherParticipant: mapParticipant(other),
    listingId: row.listing_id,
    lastMessagePreview: row.last_message_preview,
    lastMessageAt: row.last_message_at,
    createdAt: row.created_at,
  };
}

async function assertParticipant(conversationId, userId) {
  const { data, error } = await supabaseAdmin
    .from('conversations')
    .select('id, participant_one_id, participant_two_id')
    .eq('id', conversationId)
    .single();

  if (error || !data) throw AppError.notFound('Conversation not found', 'CONVERSATION_NOT_FOUND');
  if (data.participant_one_id !== userId && data.participant_two_id !== userId) {
    throw AppError.forbidden('You are not a participant in this conversation', 'NOT_PARTICIPANT');
  }
  return data;
}

async function listConversations(userId) {
  const { data, error } = await supabaseAdmin
    .from('conversations')
    .select('*, one:profiles!conversations_participant_one_id_fkey ( id, full_name, avatar_url ), two:profiles!conversations_participant_two_id_fkey ( id, full_name, avatar_url )')
    .or(`participant_one_id.eq.${userId},participant_two_id.eq.${userId}`)
    .order('last_message_at', { ascending: false, nullsFirst: false });

  if (error) throw AppError.internal('Failed to load conversations');

  const conversations = data.map((row) => mapConversation(row, userId));

  const unreadCounts = await Promise.all(
    conversations.map(async (c) => {
      const { count } = await supabaseAdmin
        .from('messages')
        .select('id', { count: 'exact', head: true })
        .eq('conversation_id', c.id)
        .neq('sender_id', userId)
        .is('read_at', null);
      return { id: c.id, unreadCount: count ?? 0 };
    }),
  );
  const unreadById = Object.fromEntries(unreadCounts.map((u) => [u.id, u.unreadCount]));

  return conversations.map((c) => ({ ...c, unreadCount: unreadById[c.id] ?? 0 }));
}

async function listMessages(conversationId, userId, { page, pageSize }) {
  await assertParticipant(conversationId, userId);

  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  const { data, error, count } = await supabaseAdmin
    .from('messages')
    .select('*', { count: 'exact' })
    .eq('conversation_id', conversationId)
    .order('created_at', { ascending: false })
    .range(from, to);

  if (error) throw AppError.internal('Failed to load messages');

  return {
    items: data.map(mapMessage),
    page,
    pageSize,
    total: count ?? 0,
    totalPages: Math.ceil((count ?? 0) / pageSize),
  };
}

async function sendMessage(conversationId, senderId, payload) {
  const conversation = await assertParticipant(conversationId, senderId);

  const { data, error } = await supabaseAdmin
    .from('messages')
    .insert({ conversation_id: conversationId, sender_id: senderId, type: payload.type, content: payload.content })
    .select('*')
    .single();

  if (error) throw AppError.internal('Failed to send message');

  const recipientId = conversation.participant_one_id === senderId
    ? conversation.participant_two_id
    : conversation.participant_one_id;

  return { message: mapMessage(data), recipientId };
}

async function markMessagesRead(conversationId, userId) {
  await assertParticipant(conversationId, userId);

  const { data, error } = await supabaseAdmin
    .from('messages')
    .update({ read_at: new Date().toISOString() })
    .eq('conversation_id', conversationId)
    .neq('sender_id', userId)
    .is('read_at', null)
    .select('id');

  if (error) throw AppError.internal('Failed to mark messages as read');
  return data.length;
}

module.exports = { getOrCreateConversation, listConversations, listMessages, sendMessage, markMessagesRead, assertParticipant };
