# Platform Requirements: Low-Rejection Meeting Platform

## 1. Vision & Problem Statement

**Problem:** People avoid putting themselves out there to meet others because they fear the embarrassment of being rejected (e.g. asking someone out, sending a like that isn't reciprocated, or being ignored).

**Solution:** A platform where people **register the email address(es)** of whoever they are interested in. No one is notified when they are added. A **match** occurs only when two people have each registered the other's email. Then both receive an **in-app notification** with the other person's name and email, and are asked whether they would like to share their mobile number with their match. No one ever sees "they're not interested"—they only see a match when it's mutual.

### How It Works

1. **Person A** joins the service and registers **Person B's email** in the database as someone they're interested in. Person B is not notified.
2. **Person B** joins the service and registers **Person A's email** as someone they're interested in.
3. The system detects that both have registered each other's email → **match**.
4. The platform sends **both** Person A and Person B an **in-app notification** that includes the **name and email address** of the person they matched with. Each party is also asked whether they would like to **share their mobile number** with that person.
5. At no point does either person see that the other "isn't interested"; they only learn about each other when there is a match.

### Work vs Personal Email (Why the Platform Is Viable)

In practice, knowing someone's email often happens **at work**—where many romances start. At work you can know or find out a colleague's **work email**, but you usually don't know their **personal email**. To make this platform viable:

- **Join with a personal email.** Users create an account using their **personal email** (and verify it). That keeps participation private from the employer and avoids using work systems for dating/interest.
- **Register interest with work email.** Users add the **work email(s)** of the person or people they're interested in—because that's the address they know.
- **Link work email to your account.** So that matches can be resolved, each user **links (and verifies) their work email** to their account. The system can then resolve "interest in bob@company.com" to the user who owns that work email (and whose account is under their personal email). When both have added each other's **work** email, the system detects the match and notifies both in-app (with name and email); they can optionally share mobile numbers with each other.

So: account identity = personal email; interest registration = work email; matching requires users to link their work email so the platform can connect "someone added this work address" to the right account. Users must be able to add one or more work email addresses to their account; **every email address a person registers (personal and work) must be verified** to address security and false-address abuse.

---

## 2. Core Principles

- **No one-sided rejection:** A user never sees "they're not interested" or "they declined." They only see outcomes when there is a match.
- **Consent and control:** Matching requires mutual opt-in (each has registered the other's email).
- **Privacy and safety:** Adding someone's email is private; the other person is never told they were added until they have also added you.

---

## 3. User Types

| User type           | Description                                                                                                                          |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| **Member**          | Registered user looking to meet others (dates, friends, or other goals depending on product scope).                                  |
| **Admin / Support** | Platform operators who use the web-based administration portal to operate the platform (safety, moderation, configuration, support). |

---

## 3.1 Platform & Administration

- **Member-facing platform:** **Native mobile apps** only — **Apple (iOS)** and **Android**. Members use the mobile apps to join, verify emails, manage their interest list, and receive match notifications (with name and email) and optionally share their mobile number with matches.
- **Administration:** A **web-based administration portal** is required for the operation of the platform. Administrators use this portal (not the mobile apps) to run and manage the service. Details of what is required from an administration perspective will follow.

---

## 4. Functional Requirements

### 4.1 User Registration (Joining the Service)

- **R1.1** A user joins the service by registering with their **personal email address** (and any required fields, e.g. password, display name). That personal email is their **account identity**—so participation is private from the workplace.
- **R1.2** **Every email address a user registers must be verified.** This is required for security and to prevent people from claiming false or someone else's email addresses.
- **R1.3** **Personal email verification:** Done in the typical manner—the platform sends a **verification link** to the personal email address; the user clicks it to confirm they control that inbox. Once verified, they can log in and receive match notifications at that address.
- **R1.4** **Work email verification:** The same approach (sending a verification link to the work address) **cannot be relied on** for workplace email addresses, because **corporate firewalls may block incoming email from this site**. A different verification method is required for work email. _(The process by which a user registers and verifies their workplace email address is described in the next section.)_
- **R1.5** The user can **record one or more matchable email addresses** on their account (in practice usually **work emails** they control). **Matchable** means: after verification, each address can be used by others who add it to their interest list to **resolve mutual matches** against this user (**R2.4**). Every matchable address **must be verified** using the work-email verification flow (see below). Users can **remove** any matchable address **at any time** from their account. After removal, that address **must no longer be used to resolve new mutual matches** for this account (for example when the user **leaves an employer**, switches organisations, or simply **does not want to be matched** via that inbox anymore). Removing a matchable address **must not** notify other users or imply one-sided rejection (**R2.2**, **R3.3**). **Existing** matches created while the address was active remain subject to normal match, history, and **unmatch/block** behaviour (**R4.4**) unless documented otherwise.
- **R1.6** Optional: minimal profile (e.g. display name, photo) used only after a match (e.g. shown in the match notification). No discovery feed, so no "pre-match" profile browsing.

### 4.1.1 Workplace email registration and verification

Because corporate firewalls may block **incoming** email from the platform, work email is verified by having the user send an email **from** their work address **to** the service. The flow is as follows:

1. **Request confirmation.** The user enters their workplace email address in the application and presses a button labeled **"Request confirmation"**.
2. **Code generation and display.** The system generates a **randomized 6-digit alphanumeric code** and **displays it to the user** (e.g. on screen). The user must use this code in the next step.
3. **User sends email from work.** The user sends an email **from their workplace email service** (e.g. Outlook, Gmail for work) **to the platform's designated address**. The email must have the **6-digit code in the subject line** of the email.
4. **Service validates.** When the service receives the email, it:
   - Verifies that the **code in the subject line** matches the code that was generated for that user/session.
   - Verifies that the **sender (From) email address** of the received email matches the workplace email address the user entered when requesting confirmation.
5. If both checks pass, the workplace email address is marked as **verified** and linked to the user's account. If not, the user can request a new code and try again.

**Security:** The generated code **must expire** so that old codes cannot be reused. The **expiration period** (e.g. 15 minutes, 1 hour) is **configurable by the platform administrators** (e.g. via admin settings or configuration).

**System requirements:** The platform must provide a **designated inbound email address** (or mechanism) that receives these verification emails, and must be able to parse the **From** address and **subject line** of incoming messages to perform the checks above. Only emails received before the code has expired shall be accepted for verification.

### 4.1.2 Multi-factor authentication (MFA)

To strengthen account security, the platform supports **multi-factor authentication** for both members and administrators.

- **R1.7** **MFA enrollment:** Users (members and admins) can **enable** multi-factor authentication on their account. The platform must support at least one second-factor method; **TOTP (authenticator app)** is required (e.g. Google Authenticator, Authy, or compatible apps). SMS or other methods may be supported as additional options at the platform’s discretion.
- **R1.8** **Login with MFA:** When MFA is enabled, after the user successfully enters their password the system must prompt for the second factor (e.g. a one-time code from the authenticator app). Access is granted only after both factors are validated.
- **R1.9** **Recovery:** The platform must provide a **recovery path** for users who lose access to their second factor (e.g. lost device). Options include: one-time **recovery codes** shown at MFA enrollment (user must store them securely), and/or a **recovery flow** (e.g. verified email link or support process) so users can regain access without losing their account. Recovery must not undermine the security benefit of MFA (e.g. avoid single-email recovery without delay or additional checks if policy requires).
- **R1.10** **Admin MFA:** Administrators must use multi-factor authentication when signing in to the administration portal. MFA for admin accounts may be **mandatory** (enforced at first login or by policy) or **strongly recommended** and configurable by the platform; the chosen policy must be documented.
- **R1.11** **MFA and sessions:** The platform must treat MFA as part of the authentication step. Existing sessions (e.g. long-lived tokens) created before MFA was enabled may be invalidated or subject to re-authentication when MFA is turned on; behaviour should be consistent and documented (e.g. “enabling MFA logs out other devices”).

### 4.2 Registering Interest (Work Email)

- **R2.1** A logged-in user can **add one or more (work) email addresses** to a private list of "people I'm interested in." In practice these will usually be **work emails** (the addresses they know from the workplace). For each entry, the user can **record the name of the person** who belongs to that email address (e.g. so they can identify "Bob Smith" for bob.smith@company.com in their list). Each entry is stored in the database with the email and, if provided, the name (e.g. "User A is interested in bob@company.com — Bob Smith").
- **R2.2** **No notification** is sent to the person whose email was added. They never learn they were added unless they also add the first person's (work) email and a match is created.
- **R2.3** Users can add or remove emails from their interest list at any time. The system never shows "they're not interested" or "they didn't add you"—only match/no match.
- **R2.4** The system matches "interest in X@company.com" to the **account that has linked and verified** that work email (even though that account logs in with a personal email). So matching is based on **work email** on both sides.
- **R2.5** Members can **review and maintain** their list of people they're interested in. They can **view** the list (each entry showing the email and, if recorded, the person's name), **add** new entries, **edit** existing entries (e.g. update the name), and **remove** entries. The list is private and used only for matching; no one else sees it.

#### Pause matching (inactive state)

Some members will want to **stop receiving new match activity** temporarily (e.g. they enter a relationship) **without** deleting people from their interest list. The product must support an explicit **pause** / **inactive-for-matching** state.

- **R2.6** Members can **turn matching off and on** via a clear control (e.g. “Pause matching” / “Active for matching”). While matching is **paused**:
  - Their **interest list is unchanged**; they must **not** be forced to remove addresses of people they are interested in.
  - Mutual-interest **match records** may still be created when the usual criteria are met (see **R3.4**); the platform **does not** infer rejection from pause.
- **R2.7** While a member has matching **paused**, the system **must not deliver** to that member the **in-app** (and **push** / **email**, if used) **notifications** that announce **new** matches that formed **during** the paused period. Those notifications are **held as pending** for that user until matching is **resumed**.
- **R2.8** When the member **resumes** matching, the system **must deliver all pending match notifications** for matches that occurred **while they were paused** (so they do not lose legitimate mutual matches). Delivery order should be **chronological by match time** unless a different ordering is documented.
- **R2.9** **Per-user delivery:** Another party who is **not** paused continues to receive **their** match notifications when the match is created, according to normal rules. One member’s pause affects **only** that member’s notification timing, not the other’s right to be notified when mutual interest exists.

#### Match and notification history

- **R2.10** Members must be able to **browse the history of their matches** in chronological order (oldest→newest or newest→oldest—pick one in UX and stay consistent). For **each** match, the history shows **who** they matched with (**counterparty identity**: at minimum the **name and email address** stored for that match, consistent with notifications elsewhere) and **when the match occurred** (an explicit **timestamp** for the moment mutual interest was recorded / the match was created). Optionally, the same row may also show **when this member was notified** if that differs (e.g. they had matching paused and were notified only on resume—**R2.8**). The system must persist **seen/read state** per member per match (e.g. **seen at** timestamp): a match counts as **“new”** until the member has viewed or acknowledged it in the app (typically **`notified_at` present and `seen_at` null**). Members must be able to clear “new” state by viewing the match (and optionally **“mark all as read”**).

### 4.3 Match Detection

- **R3.0** Matching uses **work email**. When a user **joins**, they link their work email; the system can then resolve "interest in work-email X" to the account that linked X. When a user **adds a work email** to their interest list, the system checks: is that work email linked to an existing account that has already added the current user's **work email**? If so, it's a match. (Current user's "work email" means the work email they linked to their account.)
- **R3.1** A **match** is created only when **both** have registered each other's **work email** (Person A has B's work email in their list, and Person B has A's work email in their list). Order of registration does not matter. Both users must have linked and verified their work email for matching to work.
- **R3.2** When a match is detected, the system sends **both users an in-app notification** that includes the **name and email address** of the person they matched with—**subject to R2.7–R2.9** when either user has matching paused. The application does not open a chat; it only delivers this notification. Both parties are then **asked whether they would like to share their mobile number** with the person they matched with (again respecting pause-related deferral for prompts if required for consistency with notifications—see open decision below).
- **R3.3** The system never reveals one-sided interest (e.g. no "Someone added you—sign up to see who!" that implies others didn't).
- **R3.4** **Pause and match creation:** Pausing matching **does not** remove interests and **does not** block **creation** of a match row when mutual interest exists (unless explicitly decided otherwise for legal/product reasons). Pause primarily controls **notification** (and related prompts) **to the paused user** as described in **R2.6–R2.9**.

### 4.4 Matching & Post-Match (Notification & Contact Sharing)

- **R4.1** Matches are symmetric in **data**: both users are parties to the same match record. **Notifications** may arrive at different times if one user has matching paused (**R2.9**); when a notification is delivered, each party sees the other's name and email in line with **R3.2**.
- **R4.2** The in-app notification **includes the name and email address** of the person they matched with. Users can view **current** matches (each showing name and email as provided) and **browse full match history** with **counterparty** and **match occurrence time**, per **R2.10**.
- **R4.3** After the match notification, **each party is asked if they would like to share their mobile number** with the person they matched with. Sharing is optional and at the user's choice; the platform delivers the number to the other party only when the user opts in (e.g. "Share my number with [name]?"). How and when the other party sees the shared number (e.g. only if both share, or as soon as one shares) is a product decision; the requirement is that both are prompted to decide.
- **R4.4** Users can unmatch or block; after that, the other person no longer sees them as a match (no need to expose "rejected," only "unmatched" or similar).

### 4.5 Notifications & Engagement

- **R5.1** When a match occurs, **each party receives** an in-app notification (and optional email/push) that includes the **name and email address** of the person they matched with—**except** when matching is paused for that party, in which case notifications follow **R2.7–R2.8**. The primary action is viewing the match details (name, email) in the app and being prompted to share their mobile number if they wish.
- **R5.2** If a user chooses to share their mobile number with a match, the **other party is notified** (e.g. in-app) and can see the shared number in the match view, in line with the product rules for when shared numbers are revealed.
- **R5.3** Notifications must not reveal one-sided interest (e.g. no "Someone added you—sign up to see who!").

### 4.6 Safety & Moderation (Target State)

- **R6.1** Users can report a match or another user; reports are stored and (optionally) reviewed.
- **R6.2** Users can block others; blocked users cannot see the blocker in their match list, and the blocker does not see the blocked user.
- **R6.3** Minimum age and email verification as required by policy.

---

## 5. Non-Functional Requirements

- **NFR1 – Privacy:** One-sided interest and match state are only known to the system and the two users; no public "rejection" state. Account is tied to personal email so workplace does not see participation; work email is used only for match resolution and is not shared with the employer.
- **NFR2 – Performance:** Adding an email and match detection feel instant (real-time or near real-time).
- **NFR3 – Availability:** Core flows (join, add interest emails, match, match notification and contact sharing) available with high uptime (target SLA to be set).
- **NFR4 – Usability:** Joining and adding email(s) of interest are simple enough to use without instructions.
- **NFR5 – Security:** Auth, sessions, and personal data handled with industry-standard security (e.g. HTTPS, secure storage, access control). All registered emails (personal and work) must be verified to prevent false or impersonated addresses. **Multi-factor authentication (MFA)** is supported for members and required or strongly recommended for administrators, with TOTP (authenticator app) as the primary second factor and a defined recovery process.

---

## 6. Scaling & Technology Considerations

The nature of the service means the user base could expand rapidly once word spreads. The following technology and architecture choices are recommended to support scaling from day one and through growth spikes.

| Area                   | Recommendation                                                                                                                                                                                                 | Rationale                                                                                                                                    |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **Backend / API**      | Stateless API services (REST or GraphQL) behind a load balancer; deploy on **auto-scaling** compute (e.g. containers/Kubernetes, or serverless functions).                                                     | Add more instances under load; no single bottleneck; scale out horizontally.                                                                 |
| **Database**           | Managed **relational database** (e.g. PostgreSQL, MySQL) with **connection pooling**; add **read replicas** as traffic grows so reads (list interests, match list, match checks) scale separately from writes. | Data is relational (users, interests, matches, contact-sharing preferences); replicas avoid overloading the primary on read-heavy workloads. |
| **Caching**            | **In-memory cache** (e.g. Redis, ElastiCache) for sessions, verification codes (with TTL), and hot data (e.g. "has this work email been linked?").                                                             | Reduces database load and keeps code-expiry logic fast; sessions scale across API instances.                                                 |
| **Message queue**      | **Async job queue** (e.g. SQS, RabbitMQ, Redis Queue) for: sending verification/push/email notifications, processing inbound verification emails, match notifications.                                         | Decouples API from slow or bursty work; workers can scale independently; avoids timeouts when sending many notifications.                    |
| **Inbound email**      | Use a **scalable email ingestion** service (e.g. SendGrid Inbound Parse, Mailgun Routes, AWS SES + SNS/Lambda) that pushes parsed messages to your queue/API; avoid polling a single mailbox.                  | Handles high volume of verification emails; parsing and validation can run in workers that scale.                                            |
| **Real-time / push**   | **Push notifications** (FCM, APNs) and in-app notification delivery for match alerts and optional "contact shared" updates. Real-time chat is out of scope for the initial version.                            | Match notifications and optional contact-sharing updates need to reach users promptly; managed push gateways simplify delivery.              |
| **Push notifications** | **Platform push gateways** (FCM for Android, APNs for iOS) via a single integration (e.g. Firebase Cloud Messaging for both, or OneSignal) that handles batching and retries.                                  | Native mobile requires push; a single vendor simplifies scaling and delivery.                                                                |
| **Hosting**            | **Cloud provider** with auto-scaling (AWS, GCP, or Azure); use **managed services** for DB, cache, queue, and email where possible to avoid operational bottlenecks.                                           | Reduces undifferentiated heavy lifting; scale is handled by the provider; pay for what you use.                                              |
| **Admin portal**       | Web app (e.g. SPA) calling the same API with admin auth, or a separate admin API; **rate limit and lock down** by IP/role.                                                                                     | Reuse scalability of main API; keep admin traffic and abuse surface small.                                                                   |

**Principles:** Prefer stateless services, horizontal scaling, managed services for DB/cache/queue/email, and async processing for notifications and email verification so the system can absorb rapid growth and traffic spikes without redesign.

---

## 7. Out of Scope (for Initial Version)

- **In-app chat.** When a match is detected, the platform only provides an in-app notification (name and email) and the option to share mobile numbers; it does not open or provide a chat window. Chat may be added in a later version.
- Video or voice calls (can be added later).
- Browsing or discovering strangers on the platform (this product is email-based: you add people you already have in mind).
- Public profiles or social graph visible to others.
- Any feature that exposes "they're not interested" or "they didn't add you" to the user.

---

## 8. Success Criteria

- Users can join with personal email (verified), **record one or more verified matchable emails** (typically work) used for matching, **remove** those addresses when they no longer apply (e.g. leaving an employer), and add one or more work email addresses of people they're interested in.
- No one is notified when their email is added; they only learn about mutual interest when there is a match.
- Matches are created only when both have linked their work email and registered each other's work email; both users receive an in-app notification with the match's name and email and are prompted to share their mobile number if they wish.
- No user is shown that they were "rejected" or "not added"; they only see matches (and optionally "unmatched" if they choose to remove a match).
- Users report low anxiety around adding someone's email, since the other person never sees one-sided interest (measurable via surveys or retention).

---

## 9. Open Decisions

- **Meeting goal:** Dating only, friendship, or multi-purpose (e.g. "networking," "activity partners")?
- **Limit on emails:** Max number of "interested" (work) emails per user (e.g. one at a time, or a small list)?
- **Multiple matchable emails:** Handled under **R1.5** (one or more per account; each verified; user may remove any). Further caps or UX limits TBD.
- **If the other person never joins:** Interest stays in the database with no notification; decide whether to allow removing an email from the list or reminders.
- **Employer/IT visibility:** With work verification, the user _sends_ an email from work to the platform (outbound). Consider whether the verification address and subject/code are neutral. Support for non-work addresses (e.g. university) TBD.
- **Inbound email for verification:** How the platform receives verification emails (e.g. dedicated address, mail provider, polling vs webhook) and default code expiration value for admin configuration.
- **Monetization:** Freemium (e.g. limit number of interests), subscription, or ad-supported?
- **MFA for members:** Whether MFA is optional, encouraged, or mandatory for member accounts (admin MFA is addressed in R1.10).
- **Mobile number sharing:** Whether the other party sees a shared mobile number only when both have opted in, or as soon as one party shares (and how it is displayed in the match view).
- **Paused matching and mobile-number prompts:** Whether the “share my mobile number?” prompt for a match is **deferred** until resume (aligned with deferred notifications) or shown only when the match notification is delivered—must stay consistent with **R2.7–R2.8** and privacy expectations.

---

_Document version: 1.11 | Last updated: May 2026 — Platform: native mobile (iOS & Android) for members; web-based admin portal for operations. Admin requirements to follow. Match outcome: in-app notification (name + email) and optional mobile number sharing; no in-app chat (see 4.4, 4.5, §7). R1.5: one or more **matchable** (verified) emails per user; pause matching; match history (R2.6–R2.10, R3.4)._
