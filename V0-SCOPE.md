# Version 0 (v0) — Working prototype scope

**Status:** Agreed scope for the first end-to-end prototype.  
**Full product requirements:** [REQUIREMENTS.md](./REQUIREMENTS.md) (v1.11).  
**UI reference:** [Mobile App UI.zip](./Mobile%20App%20UI.zip) (Figma export; close enough for implementation).

---

## In scope

### Authentication

| #   | Capability                      | Notes                                                                                                             |
| --- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| 0   | **Sign up / sign in**           | Personal email + password via Supabase Auth.                                                                      |
| 0   | **Personal email verification** | Verification **link** to personal inbox (R1.3); user cannot use the app until verified (or per your auth policy). |

### Matchable work email

| #   | Capability                                | Notes                                                                                                                                                                                                                                                     |
| --- | ----------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | **Add / verify one matchable work email** | Outbound-email flow: user requests confirmation → **numeric** 6-digit code shown → user sends email **from** that address with code in **subject** → platform marks address verified. One verified work email per user for v0 (schema allows more later). |

### Interests

| #   | Capability                        | Notes                                                                                                          |
| --- | --------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| 2   | **Add / edit / remove interests** | Private list: **name** (first + surname in UI) + **work email** per entry. No notification to the other party. |

### Matching

| #   | Capability          | Notes                                                                                                                                                |
| --- | ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| 3   | **Automatic match** | When both users have each other’s **verified** work email on their interest lists, create a match and per-user history rows (name + email snapshot). |

### Match experience

| #   | Capability                  | Notes                                                                                      |
| --- | --------------------------- | ------------------------------------------------------------------------------------------ |
| 4   | **Match list**              | Name, email, match **timestamp**, **new / read** state, **share mobile** toggle per match. |
| 5   | **Pause / resume matching** | Member can pause and resume; interest list unchanged while paused.                         |

---

## Explicitly out of scope for v0

Defer to a later version unless noted otherwise:

- **MFA** (R1.7–R1.11)
- **Admin portal**
- **Push / email** match notifications (in-app / Realtime only for v0)
- **Deferred notifications while paused** (R2.7–R2.8) — pause toggles state only; deliver matches immediately to non-paused users; paused user behavior simplified for v0
- **Report, block, unmatch** (R6.1–R6.2, R4.4)
- **In-app chat**, discovery, public profiles (§7)
- **Multiple matchable work emails** per user (v0 limits to **one** verified address)
- **University / email-type** selector (work email only in v0)
- **SMS verification** of mobile at signup (mobile collected on profile; sharing is post-match only)
- **Inbound work-email webhook** required for demo — manual verify or “skip verification” in dev is acceptable until webhook is built
- **Alpphanumeric** verification code and exact button label **“Request confirmation”** (numeric code and current UI labels are fine for v0)
- **Mark all as read**, **notified_at** display in UI (per-match read is in scope)
- **Counterparty “they shared their number”** notification flow (R5.2) — v0: toggle records intent; full bilateral reveal rules TBD

---

## v0 assumptions (decide once, implement consistently)

1. **Mobile number sharing:** When a member turns on **Share mobile** for a match, the **other party can see that number** in the match view (as soon as one shares). Both parties get an independent toggle.
2. **Interest name:** Required in the app for v0 (stored as `subject_display_name`, e.g. `"First Last"`).
3. **Match “new”:** `notified_at` set when match is created; **new** while `seen_at` is null; viewing the match or **Mark as read** sets `seen_at`.
4. **Pause:** Updates `profiles.matching_paused` and appends `matching_pause_events`. v0 does **not** queue/hold notifications for paused users.
5. **Platform:** Member app = **Expo (React Native)** under `apps/mobile/`; backend = **Supabase** (existing migrations).

---

## Requirement mapping (traceability)

| v0 item                             | Primary requirements               |
| ----------------------------------- | ---------------------------------- |
| Sign up / sign in + personal verify | R1.1–R1.3                          |
| One verified matchable work email   | R1.4–R1.5, §4.1.1                  |
| Interest CRUD                       | R2.1–R2.5                          |
| Auto match                          | R3.0–R3.1                          |
| Match list + share mobile           | R3.2, R4.2–R4.3, R2.10 (partial)   |
| Pause / resume                      | R2.6 (partial; no R2.7–R2.8 in v0) |

---

## Backend alignment

Existing migrations cover most of v0:

| Area            | Table / column                                                                       |
| --------------- | ------------------------------------------------------------------------------------ |
| Profile         | `profiles` (`firstname`, `surname`, `matching_paused`)                               |
| Matchable email | `profile_work_emails`                                                                |
| Interests       | `interest_entries` (`subject_display_name`, `interest_email`)                        |
| Matches         | `matches`, `match_history_entries` (`seen_at`, `notified_at`, counterparty snapshot) |
| Pause history   | `matching_pause_events`                                                              |

**Build tasks for v0 (not yet in schema):**

- **Match detection** — trigger or Edge Function on `interest_entries` insert/update.
- **Mobile share per match** — e.g. `match_contact_shares` (match_id, user_id, shared_at) or columns on `match_history_entries`.
- **Work-email verification session** — pending code, expiry, normalized email (table or Edge Function + KV).
- **Profile mobile** — optional column on `profiles` if not stored only in Auth metadata.

---

## Definition of done (v0 demo)

Two test accounts can:

1. Register with personal email and complete link verification.
2. Each adds and verifies **one** work email (real or dev skip).
3. Each adds the other’s work email to their interest list (with name).
4. System creates a **match**; both see it in the match list with name, email, and time.
5. Either can mark a match read and toggle **share mobile**.
6. Either can **pause** matching (banner/state) and **resume** without losing interests.

---

## Implementation order

1. Supabase: match detection + mobile-share migration + work-email verification stub.
2. `apps/mobile`: Expo scaffold → auth → work email → interests → matches → pause.
3. Seed data + short demo script for two users.

See [NEXT-STEPS.md](./NEXT-STEPS.md) for the wider roadmap beyond v0.

---

_Document version: 1.0 | Agreed: May 2026_
