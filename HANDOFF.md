# BhoomiSetu — Project Handoff

Paste this whole file into a new Claude Code chat to pick up where this session left off.

## What this is

BhoomiSetu: Flutter + Node/Express + Supabase agricultural trade platform connecting farmers, buyers, and agricultural experts. Repo: `E:\andrioid app` (Flutter app in `app/`, backend in `backend/`, DB migrations in `supabase/migrations/`).

- GitHub: https://github.com/saaki05/bhoomisetu (main branch). If a push gets a 403 permission error, run `gh auth status` to check which account is active and `gh auth switch --user saaki05` to fix it.
- Backend deployed on Render (free tier): https://bhoomisetu-backend.onrender.com — auto-deploys on push to `main` (see `render.yaml`). Free tier cold-starts after ~15min idle (30-50s wake time).
- Database: Supabase project `qvojkpznwlucohxgbrkd` (Postgres + Auth). Direct DB connection is IPv6-only from this dev machine's network — migrations must be pasted manually into Supabase's SQL Editor (dashboard.supabase.com → project → SQL Editor) rather than run via script.
- Flutter SDK at `E:\flutter_sdk\bin` — **not on PATH in fresh shells**, prepend `$env:Path += ";E:\flutter_sdk\bin"` in every new PowerShell session before running `flutter`/`dart`.

## What's built and working (verified against the live backend)

- **Auth**: email/password register/login, Google Sign-In, phone OTP (backend logic correct — actual sending currently blocked, see Known Issues), role selection (farmer/buyer/expert) with a post-signup picker screen for Google/OTP signups that skip it upfront.
- **Home**: hero header (greeting + weather combined), quick-actions row (Marketplace/Orders/Chat/Farm Tools), market prices, nearby buyers, government schemes.
- **Weather**: Open-Meteo (free, keyless). Uses the device's real GPS location (via `geolocator`) reverse-geocoded through Nominatim, falls back to the user's saved district, then to New Delhi as a last resort. Both geocoding and forecast responses are cached server-side (20min TTL) to avoid Open-Meteo's rate limits.
- **Marketplace**: crop listings (farmer posts, buyer orders directly — no shopping cart, it's a P2P listing model not an e-commerce catalog), search/filter, categories with colored icon tiles, bookmarks.
- **Orders**: place order against a listing, status transitions (pending→accepted→preparing→out_for_delivery→delivered, or rejected/cancelled), reviews.
- **Chat**: realtime via Socket.IO, JWT-authenticated.
- **Farm Tools** (new, client-side only, no backend): fertilizer calculator (crop + acreage → Urea/DAP/MOP dosage via standard NPK reference tables) and profit calculator (revenue − costs).
- **Localization**: EN/HI scaffolding wired up for real (`app/lib/l10n/*.arb`, generated delegates, a working language-picker bottom sheet, `context.l10n` extension). Only Login/Register/Home screens are actually migrated to use it so far — most of the app still has hardcoded English strings.

## Known issues — still open

1. **OTP doesn't send**: Supabase's Twilio phone-auth provider has the Twilio **Account SID** typed into the "From Number" field instead of an actual Twilio phone number / Messaging Service SID (`MG...`). Fix in Supabase Dashboard → Authentication → Providers → Phone. Also: if the Twilio account is a trial, it can only text pre-verified numbers.
2. **Google Sign-In on the release APK**: needs the release keystore's SHA-1 registered as a *second* Android OAuth client in Google Cloud Console (package name same as the debug client, can't just replace the debug fingerprint — that UI only takes one SHA-1 per client). This was done this session (client `731447998944-ol5asr8s26qjb4lju43cqd21q2e08js3.apps.googleusercontent.com`) but Google says propagation can take a few minutes to hours.
3. **CORS wildcard bug — fixed but verify it's still deployed**: `backend/src/app.js` and `backend/src/sockets/index.js` compute CORS origin as `env.CLIENT_ORIGIN !== '*' ? split(',') : true` — if `CLIENT_ORIGIN=*` gets passed to the `cors` npm package as a literal array `['*']`, every browser request gets rejected (native/mobile apps are unaffected since CORS is browser-only). This was the root cause of "nothing works" when testing via the Flutter web build. Confirmed fixed and deployed as of this handoff.
4. **Migration 0007 (`role_selected` column)**: already applied to the live DB. If starting a fresh Supabase project, re-run `supabase/migrations/0007_role_selection.sql` (and all prior numbered migrations) via the SQL Editor.

## Session's most recent commits (main branch, newest last)

```
Add role-selection flow, fix weather (Open-Meteo), point app at Render backend
Cache weather responses to avoid Open-Meteo rate limiting
Fix order details crash from snake_case history payload
Use real device GPS for weather instead of defaulting to New Delhi
Fix CORS wildcard being ignored, breaking every browser request
```

Plus uncommitted local changes at handoff time: Home screen redesign (hero header, quick actions), marketplace category icon tiles, Farm Tools feature, language switcher, and the `skipAuth: true` fix on all public auth endpoints (register/login/OTP/Google/forgot-password/reset-password) so they don't wait on a secure-storage read before firing. **Run `git status` and `git diff` first thing in the new session** to see exactly what's staged vs not.

## Build commands (PowerShell, from `app/` or `backend/`)

```powershell
$env:Path += ";E:\flutter_sdk\bin"
cd "E:\andrioid app\app"
flutter analyze
flutter test
flutter build apk --release   # signed with android/app/bhoomisetu-release.jks (gitignored, still on disk)
```

```bash
cd "/e/andrioid app/backend"
npx jest --runInBand
```

Web preview for testing without a phone: `.claude/launch.json` has a `flutter-web` config (`flutter run -d web-server --web-port 5000`) — use the Browser-pane preview tools to start/view it. Note: `flutter clean` forces a ~100s+ full rebuild before the dev server responds; don't assume it's broken if `/` 404s for the first minute or two after a clean.

## What the user actually wants right now

Demo-quality polish for what sounds like a college project ("just to show my faculty"), inspired by (not cloned from — that's a copyright line already discussed and agreed) a commercial agri-input app called AgriBegri/Kisan Krishi. Already covered: weather, mandi prices, category icons, calculators, multi-language. Explicitly declined: an AI "Crop Doctor" disease-scanner feature (would need a paid vision API key, user chose to skip it for now).

The user does not have a phone to test on — **the Flutter web build is their actual testing surface**, not just a dev convenience. Prioritize keeping that working over anything mobile-only.
