# Architecture overview

```mermaid
flowchart TD
  A[Flutter Android and Web] -->|HTTPS| B[Express API]
  A -->|Socket.IO| C[Realtime chat gateway]
  B --> D[Supabase Auth]
  B --> E[Supabase PostgreSQL]
  B --> F[Supabase Storage]
  C --> E
  B --> G[Redis cache and rate limiter]
  B --> H[Weather and market-data providers]
  I[Firebase Cloud Messaging] --> A
  J[Twilio through Supabase Phone Auth] --> D
```

The Flutter project uses feature-first Clean Architecture:

```text
presentation → Riverpod controller → use case → repository → data source → API/storage
```

The backend uses validation at routes, authenticated role checks before service calls, and Supabase Row Level Security as a database-level protection layer.
