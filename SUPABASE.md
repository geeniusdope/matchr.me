# Supabase suitability for the platform

**Summary:** Supabase is **suitable** for this product. It covers managed Postgres, auth (including personal-email verification), realtime for chat, and Edge Functions for business logic and webhooks. You add: (1) an inbound-email provider + Edge Function for work-email verification, and (2) FCM/OneSignal (or similar) for push from Edge Functions. That aligns well with the scaling/tech section and keeps the architecture simple while still scalable.

**Decision:** The platform will use **Supabase Cloud** (Supabase’s hosted offering). Supabase will **not** be self-hosted.

---

## Where Supabase fits well

| Need            | Supabase             | Notes                                                                                                                                                            |
| --------------- | -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Database**    | Yes — PostgreSQL     | Users, interests, matches, messages, verification codes. Connection pooling (PgBouncer), backups, and scaling options (including read replicas on higher plans). |
| **Auth**        | Yes — Supabase Auth  | Sign-up with personal email, **verification link** to that email, sessions/JWT. Fits R1.3 (personal email verification).                                         |
| **Realtime**    | Yes — Realtime       | Channels or Postgres change feed for **chat** and “new message” updates in the app. Scales with concurrent users.                                                |
| **API / logic** | Yes — Edge Functions | Serverless (Deno) for match detection, webhooks, and calling external services. Auto-scales.                                                                     |
| **Admin**       | Yes — same DB + Auth | Admin portal (e.g. Next.js/Vue) uses Supabase with **service role** or admin RLS; store config (e.g. code expiry) in a `settings` table.                         |

---

## What you add outside Supabase

### 1. Work email verification (send code → user emails you back)

Supabase doesn’t receive email. Use an **inbound email provider** (e.g. Resend, Mailgun, SendGrid Inbound Parse) that POSTs to an **Edge Function** when mail arrives. The function checks subject (code) and From address, then updates the DB. Supabase is suitable; you just wire this one flow.

### 2. Push notifications (iOS/Android)

Supabase doesn’t send FCM/APNs. From **Edge Functions** (e.g. on “new match” or “new message” in DB), call **Firebase Cloud Messaging** or **OneSignal**. That keeps Supabase as the core and adds one integration.

### 3. Very high async load (optional)

For “expand rapidly” you can do a lot with **DB triggers + Edge Functions** (e.g. on insert to `matches` or `messages`, trigger “send push/email”). If you later need a dedicated queue (e.g. millions of notifications), add **SQS/Redis** and have Edge Functions enqueue jobs. Not required to start.

---

## Conclusion

Supabase is suitable for this platform: managed Postgres, auth (including personal email verification), realtime for chat, and Edge Functions for business logic and webhooks. You add: (1) inbound email → Edge Function for work email verification, and (2) FCM/OneSignal (or similar) for push from Edge Functions. That aligns well with the scaling and technology section in the requirements and keeps the architecture simple while still scalable.
