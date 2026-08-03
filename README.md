# BhoomiSetu

BhoomiSetu is a Flutter mobile and web application for direct agricultural trade. Farmers can post crop stock with photos, buyers can browse and place orders, and both can communicate through real-time chat.

## What works

- Role-based account onboarding for farmers, buyers, and experts
- Email/password, Google, and Supabase/Twilio phone OTP sign-in
- Marketplace listings with stock, price, photos, filters, bookmarks, and reports
- Buyer-to-farmer ordering with status tracking and reviews
- Realtime Socket.IO chat with typing, read state, and online presence
- Weather, market-price, government-scheme, and farm-calculator experiences
- Profile editing with avatar upload, camera/gallery selection, and optional live location
- One Flutter codebase for Android and the web

## Architecture

```text
Flutter Android / Flutter Web
        │ HTTPS + Socket.IO
        ▼
Node.js / Express API on Render (or Docker)
        │
        ├── Supabase Auth, PostgreSQL, Storage, Realtime
        ├── Twilio via Supabase Phone Auth
        └── Firebase Cloud Messaging (optional push notifications)
```

## Start locally

1. Create `backend/.env` from `backend/.env.example` and enter your Supabase values.
2. Create `app/.env` from `app/.env.example` and set the public backend URL.
3. Apply every SQL file in `supabase/migrations/` in numeric order using the Supabase SQL Editor.
4. Start the API: `cd backend && npm install && npm run dev`.
5. Start the app: `cd app && flutter pub get && flutter run -d chrome`.

For a physical phone on the same network, use the LAN IP in `app/.env`. For people on different networks, deploy the API and web app as described in [Deployment](docs/DEPLOYMENT.md).

## Verification

```powershell
cd backend
npm test

cd ../app
flutter analyze
flutter test
flutter build web --release
flutter build apk --release
```

## Important privacy note

Location, camera, and gallery access are requested only after a person explicitly chooses the relevant feature. Seller phone numbers and precise location should be shared only with appropriate consent.

## Documents

- [Deployment guide](docs/DEPLOYMENT.md)
- [Environment variable reference](docs/ENVIRONMENT.md)
- [Architecture overview](docs/ARCHITECTURE.md)
