# Recommended Next Steps

Prioritized actions to move from requirements and docs to a working foundation. Adjust order based on team size and whether you need to demo quickly or build solidly.

---

## Phase 1: Foundation (Do First)

### 1. Repository and dev environment

- [ ] Follow **[STEP-01-REPOSITORY-AND-DEV-ENVIRONMENT.md](./STEP-01-REPOSITORY-AND-DEV-ENVIRONMENT.md)** for full instructions (Git, GitHub, monorepo, env template, ESLint, Prettier, Husky).
- [ ] Create a **Git repository** (GitHub, GitLab, or Bitbucket). Prefer a **monorepo** with folders such as `apps/mobile/`, `apps/admin/`, and `supabase/` (scaffold files may already exist in this repo).
- [ ] Follow **DEV-ENVIRONMENT-AND-CICD.md** for CI/CD later; use **SETUP.md** and **CONTRIBUTING.md** for day-to-day onboarding.

**Why first:** Without a shared repo and a repeatable setup, remote work and CI will be painful.

### 2. Supabase project and data model

- [ ] Create a **Supabase Cloud project** (e.g. one shared “development” project for the team).
- [ ] Design and document the **schema**:
  - **Auth:** Rely on Supabase Auth for users (personal email sign-up, verification).
  - **Profiles:** e.g. `profiles` (display name, linked work emails, optional mobile, MFA state).
  - **Work emails:** Table for verified work emails per user (user_id, email, verified_at).
  - **Interests:** User A’s list of work emails they’re interested in (and optional name per entry).
  - **Matches:** When both have each other in their interest list (match_id, user_a, user_b, created_at).
  - **Contact sharing:** Table or columns for “user chose to share mobile number with this match” and storing/displaying the shared number per match.
- [ ] Add **migrations** under `supabase/migrations/` and apply them. Set up **Row Level Security (RLS)** so users only see their own data and matches.
- [ ] Store **Supabase URL and anon key** in `.env.example`; each developer (and CI) uses env vars, no secrets in repo.

**Why second:** The app is data-driven (interests → match → notification → contact sharing). Getting the model and RLS right early avoids big refactors.

---

## Phase 2: Core backend and match flow

### 3. Match detection and notifications

- [ ] Implement **match detection**: when a user adds a work email to their interest list, check if that work email is linked to an account that already has the current user’s work email in their interest list; if so, create a match record.
- [ ] Use a **Supabase Edge Function** (or DB trigger + function) so match creation is consistent and you can trigger side effects (e.g. “notify both users”).
- [ ] **In-app notification**: when a match is created, both users must receive an in-app notification that includes the **name and email** of the person they matched with. Implement via Realtime subscription (e.g. “new row in matches for my user_id”) or a push notification that opens the app to the match detail screen.
- [ ] **Mobile number sharing**: after match, prompt each user “Share my mobile number with [name]?”. Persist their choice and, when allowed by your product rules, show the shared number to the other party in the match view.

**Why third:** This is the core value of the product; everything else (admin, polish) depends on it.

### 4. Work email verification (inbound email)

- [ ] Choose an **inbound email provider** (e.g. Resend, Mailgun, SendGrid Inbound Parse) that POSTs to your backend when mail arrives.
- [ ] Implement an **Edge Function** (or API route) that: receives the webhook, parses From + subject (6-digit code), validates code and sender against pending verification requests, then marks the work email as verified in the DB.
- [ ] Implement the **user flow** in the app: “Request confirmation” → show 6-digit code → user emails from work to your designated address with code in subject → your webhook verifies and updates DB.

**Why fourth:** Work email verification is required for matching to work; it’s a discrete piece you can build and test once the schema exists.

---

## Phase 3: Apps (mobile + admin)

### 5. Mobile app (Expo / React Native)

- [ ] Scaffold the app under `apps/mobile/` (Expo + TypeScript). Connect to Supabase (env vars for URL and anon key).
- [ ] Implement: **sign up / sign in** (personal email + verification), **link work email** (with verification flow), **interest list** (add/edit/remove work emails + optional names), **match list** and **match detail** (name, email, prompt to share mobile number, view shared number if any), and **in-app notification** when a new match appears.
- [ ] Add **MFA** (TOTP) using Supabase Auth MFA once the rest of the flow is stable.

**Why here:** Members use the mobile app for the main flow; admin is for operations and can follow.

### 6. Admin portal (React + Vite or Next.js)

- [ ] Scaffold under `apps/admin/` with TypeScript and Supabase (service role or admin RLS for operators only).
- [ ] Implement: **admin login** (and enforce MFA per R1.10), **view users/matches/reports** (read-only at first), **config** (e.g. work-email code expiration). Add **rate limiting and IP/role lockdown** as in your NFRs.

**Why here:** You need a place to operate the platform and tune settings; it doesn’t have to be feature-complete before you demo the member flow.

---

## Phase 4: Polish and scale

### 7. CI/CD and deployment

- [ ] Add **CI** (e.g. GitHub Actions): on every PR, run lint, typecheck, tests, and build both apps.
- [ ] **Deploy admin** (e.g. Vercel/Netlify) on merge to `main`.
- [ ] Use **EAS Build** for the mobile app; store credentials in CI secrets and build on tag or manual run.
- [ ] (Optional) Automate **Supabase migrations** in a release step.

### 8. Notifications and safety

- [ ] **Push notifications**: when a match is created (and optionally when the other party shares their number), send a push (FCM/APNs via Expo or OneSignal) so users see the alert even when the app is closed.
- [ ] **Email notifications**: optional “You have a new match” email; keep wording consistent with “no one-sided rejection.”
- [ ] Implement **report** and **block** (R6.1, R6.2); store reports for later review.

---

## Suggested order if you’re solo or a small team

1. **Repo + monorepo layout** → **Supabase project + schema + RLS** → **match detection + in-app notification + mobile number sharing** in the backend.
2. **Mobile app** for the full member journey (sign up, work email, interests, match list, match detail, share number).
3. **Work email verification** (inbound email + Edge Function).
4. **Admin portal** (minimal: login, view users/matches, code expiry config).
5. **CI/CD**, then **push/email** and **report/block**.

This gets you to a demonstrable “match → notification with name/email → optional share number” flow quickly, then you add verification, admin, and ops.

---

## Open decisions to resolve early

- **Mobile number sharing:** Is the shared number visible only when both have opted in, or as soon as one shares? (See REQUIREMENTS.md Open Decisions.)
- **MFA for members:** Optional, encouraged, or required? (Admin MFA is in R1.10.)
- **Domain and branding:** Pick a domain from DOMAINS.md when you’re ready to ship or run invite-only tests.

Use **DEV-ENVIRONMENT-AND-CICD.md** for detailed checklist items on repo, env, lint, and CI/CD.
