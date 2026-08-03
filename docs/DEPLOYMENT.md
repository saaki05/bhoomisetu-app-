# Deployment guide

This guide makes BhoomiSetu reachable from any mobile or Wi-Fi network. A local laptop server cannot do that; use a public HTTPS address for both the API and web app.

## 1. Supabase

1. In the Supabase dashboard, create or open the BhoomiSetu project.
2. In **SQL Editor**, run every file in `supabase/migrations/` in numeric order, including `0008_storage_buckets.sql` and `0009_listing_videos.sql`.
3. In **Authentication → URL Configuration**, add the deployed web URL and local development URL to Redirect URLs.
4. In **Authentication → Providers**, enable Email and Google. Add the Google OAuth client IDs created for Android and Web.
5. Enable Phone. Set the Twilio Account SID, Auth Token, and a real Twilio phone number or Messaging Service SID (`MG...`). A Twilio trial can text only verified recipient numbers.

Never put the Supabase service-role key in the Flutter app. It belongs only in the deployed API environment.

## 2. Deploy the API to Render

The repository contains `render.yaml`. Create a Render Web Service from the Git repository and let Render read that file.

Set these secret environment values in Render:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `JWT_ACCESS_SECRET`
- `JWT_REFRESH_SECRET`
- `CLIENT_ORIGIN` — the final web-app domain, or `*` for a private faculty demo
- `WEATHER_API_KEY` only if using a keyed weather provider

After deployment, open `https://YOUR-API/api/v1/health`. A JSON health response confirms that users on any network can reach the backend.

## 3. Deploy the web app

Set `app/.env` before building:

```env
API_BASE_URL=https://YOUR-API.onrender.com/api/v1
SOCKET_URL=https://YOUR-API.onrender.com
```

Then run:

```powershell
cd app
flutter pub get
flutter build web --release
```

Deploy `app/build/web` to Firebase Hosting, Netlify, Vercel, or Render Static Site. Add that resulting HTTPS URL to Render `CLIENT_ORIGIN` and Supabase redirect URLs.

## 4. Firebase notifications

1. Create a Firebase project and add Android package `com.bhoomisetu.bhoomisetu` and the deployed Web app.
2. Download `google-services.json` to `app/android/app/` (this file must not be committed).
3. Generate FlutterFire configuration with `flutterfire configure`; it creates `lib/firebase_options.dart`.
4. Add the Firebase Web configuration and Messaging service worker for the web deployment.
5. Use a Firebase service-account credential only in a protected backend environment when sending push notifications.

## 5. Android release

Set the deployed HTTPS URLs in `app/.env`, then build:

```powershell
cd app
flutter build apk --release
```

The APK can be shared with testers. Since it uses a public HTTPS API, each tester may use a different mobile network.

## 6. Docker alternative

For a local API plus Redis:

```powershell
docker compose up --build
```

Supabase remains the managed database/auth/storage service, so it is not replaced by this compose setup.
