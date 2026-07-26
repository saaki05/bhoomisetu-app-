const { createClient } = require('@supabase/supabase-js');
const { loadEnv } = require('./env');

const env = loadEnv();

/**
 * Service-role client: bypasses RLS. This backend is the single trusted
 * intermediary between the Flutter app and Postgres — the app never talks
 * to Supabase directly, so every data-access query in this codebase goes
 * through this client and authorization is enforced explicitly in Express
 * middleware/controllers. RLS policies in the SQL migrations remain as
 * defense-in-depth (e.g. against a leaked key being used outside this API).
 */
const supabaseAdmin = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY, {
  auth: { autoRefreshToken: false, persistSession: false },
});

/**
 * Anon-key client used only for the handful of GoTrue auth flows that must
 * go through the public API rather than the admin API: password sign-in,
 * OTP request/verify, Google ID-token sign-in, and password-reset emails.
 * Every other query in the app uses `supabaseAdmin`.
 */
const supabaseAuth = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY, {
  auth: { autoRefreshToken: false, persistSession: false },
});

module.exports = { supabaseAdmin, supabaseAuth };
