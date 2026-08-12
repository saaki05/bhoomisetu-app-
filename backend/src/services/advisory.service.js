const { loadEnv } = require('../config/env');
const logger = require('../config/logger');
const AppError = require('../utils/AppError');

const env = loadEnv();

const GROQ_CHAT_COMPLETIONS_URL = 'https://api.groq.com/openai/v1/chat/completions';

const SYSTEM_PROMPT = `You are the AI Farming Advisor inside BhoomiSetu, an Indian agricultural
trade and farming assistance app. You help farmers, buyers, and agricultural
experts with practical, actionable advice on: crop selection and rotation,
fertilizer and pesticide guidance, pest and disease identification from
descriptions, irrigation scheduling, soil health, harvest timing, and general
farming best practices for Indian conditions and climate.

Keep answers concise, practical, and specific — prefer concrete steps and
quantities over vague generalities. When a question depends on details you
don't have (crop variety, region, soil type, season), briefly ask for them
rather than guessing. If asked something outside agriculture/farming, gently
redirect back to how you can help with their farming or trading needs.`;

/**
 * Sends a chat turn to Groq's OpenAI-compatible chat completions API and
 * returns the assistant's reply text.
 */
async function sendChatMessage({ message, history }) {
  if (!env.GROQ_API_KEY) {
    throw AppError.internal(
      'The AI advisor is not configured yet. Set GROQ_API_KEY on the server to enable it.',
      'ADVISORY_NOT_CONFIGURED',
    );
  }

  const messages = [
    { role: 'system', content: SYSTEM_PROMPT },
    ...history.map((turn) => ({ role: turn.role, content: turn.content })),
    { role: 'user', content: message },
  ];

  let response;
  try {
    response = await fetch(GROQ_CHAT_COMPLETIONS_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${env.GROQ_API_KEY}`,
      },
      body: JSON.stringify({
        model: env.GROQ_MODEL,
        messages,
        temperature: 0.4,
        max_tokens: 700,
      }),
      signal: AbortSignal.timeout(20000),
    });
  } catch (error) {
    logger.error('Groq request failed', { error: error.message });
    throw AppError.internal('Failed to reach the AI advisor, please try again', 'ADVISORY_REQUEST_FAILED');
  }

  if (!response.ok) {
    const body = await response.text().catch(() => '');
    logger.error('Groq returned an error response', { status: response.status, body });
    throw AppError.internal('The AI advisor is temporarily unavailable', 'ADVISORY_UPSTREAM_ERROR');
  }

  const data = await response.json();
  const reply = data.choices?.[0]?.message?.content?.trim();

  if (!reply) {
    throw AppError.internal('The AI advisor returned an empty response', 'ADVISORY_EMPTY_RESPONSE');
  }

  return { reply, model: data.model ?? env.GROQ_MODEL };
}

module.exports = { sendChatMessage };
