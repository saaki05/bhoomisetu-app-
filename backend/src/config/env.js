const { z } = require('zod');

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().default(4000),
  API_BASE_URL: z.string().default('http://localhost:4000'),
  CLIENT_ORIGIN: z.string().default('http://localhost:8080'),

  SUPABASE_URL: z.string().min(1, 'SUPABASE_URL is required'),
  // Accepts both the legacy anon/service_role JWTs and Supabase's newer
  // sb_publishable_.../sb_secret_... key format — supabase-js treats
  // either as a drop-in value for these two client constructors.
  SUPABASE_ANON_KEY: z.string().min(1, 'SUPABASE_ANON_KEY is required'),
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1, 'SUPABASE_SERVICE_ROLE_KEY is required'),

  JWT_ACCESS_SECRET: z.string().min(16, 'JWT_ACCESS_SECRET must be at least 16 characters'),
  JWT_REFRESH_SECRET: z.string().min(16, 'JWT_REFRESH_SECRET must be at least 16 characters'),
  JWT_ACCESS_EXPIRES_IN: z.string().default('15m'),
  JWT_REFRESH_EXPIRES_IN: z.string().default('30d'),

  // Optional: when unset, rate limiting and refresh-token revocation fall
  // back to in-memory storage (fine for a single instance; a horizontally
  // scaled deployment should set this to share state across instances).
  REDIS_URL: z.string().optional().default(''),

  RATE_LIMIT_WINDOW_MS: z.coerce.number().default(900000),
  RATE_LIMIT_MAX: z.coerce.number().default(300),

  SMS_PROVIDER_API_KEY: z.string().optional().default(''),
  SMS_PROVIDER_SENDER_ID: z.string().optional().default('BHMSTU'),

  EMAIL_FROM: z.string().optional().default('no-reply@bhoomisetu.app'),
  SMTP_HOST: z.string().optional().default(''),
  SMTP_PORT: z.coerce.number().optional().default(587),
  SMTP_USER: z.string().optional().default(''),
  SMTP_PASSWORD: z.string().optional().default(''),

  CLOUDINARY_CLOUD_NAME: z.string().optional().default(''),
  CLOUDINARY_API_KEY: z.string().optional().default(''),
  CLOUDINARY_API_SECRET: z.string().optional().default(''),

  WEATHER_API_KEY: z.string().optional().default(''),
  WEATHER_API_BASE_URL: z.string().optional().default('https://api.openweathermap.org/data/2.5'),

  GOOGLE_MAPS_API_KEY: z.string().optional().default(''),

  MARKET_PRICE_API_KEY: z.string().optional().default(''),
  MARKET_PRICE_API_BASE_URL: z.string().optional().default(''),

  BOOTSTRAP_DEMO_CATALOG: z
    .enum(['true', 'false'])
    .optional()
    .default('true')
    .transform((value) => value === 'true'),

  LOG_LEVEL: z.enum(['error', 'warn', 'info', 'http', 'debug']).default('info'),
});

function loadEnv() {
  const parsed = envSchema.safeParse(process.env);
  if (!parsed.success) {
    const issues = parsed.error.issues
      .map((issue) => `  - ${issue.path.join('.')}: ${issue.message}`)
      .join('\n');
    throw new Error(`Invalid environment configuration:\n${issues}`);
  }
  return parsed.data;
}

module.exports = { loadEnv };
