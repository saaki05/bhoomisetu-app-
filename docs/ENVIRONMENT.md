# Environment variables

## Flutter: `app/.env`

| Name | Required | Purpose |
|---|---:|---|
| `API_BASE_URL` | Yes | Public API base URL ending in `/api/v1` |
| `SOCKET_URL` | Yes | Public Socket.IO origin |
| `SUPABASE_URL` | Yes | Supabase project URL |
| `SUPABASE_ANON_KEY` | Yes | Public Supabase anonymous key |
| `GOOGLE_MAPS_API_KEY` | Optional | Interactive maps |
| `GOOGLE_SIGN_IN_WEB_CLIENT_ID` | For web Google sign-in | OAuth client ID |

## Backend: `backend/.env`

| Name | Required | Purpose |
|---|---:|---|
| `SUPABASE_URL` | Yes | Supabase project URL |
| `SUPABASE_ANON_KEY` | Yes | Supabase anonymous key |
| `SUPABASE_SERVICE_ROLE_KEY` | Yes | Trusted server-only Supabase key |
| `JWT_ACCESS_SECRET` | Yes | API access token signing key |
| `JWT_REFRESH_SECRET` | Yes | API refresh token signing key |
| `CLIENT_ORIGIN` | Yes | Web app origin used for browser CORS |
| `REDIS_URL` | Production recommended | Cross-instance rate limiting and caching |

Secrets must stay in local `.env` files or the hosting provider’s secret manager. Do not commit them.
