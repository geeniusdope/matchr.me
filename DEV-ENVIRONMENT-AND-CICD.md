# Development Environment & CI/CD Plan

Plan for setting up a **remote-friendly development environment** and **CI/CD pipeline** for the Low-Rejection Meeting Platform. Stack: Supabase, React Native (Expo), React (Vite or Next.js) admin portal.

---

## 1. Repository & Version Control

### 1.1 Choose repository structure

| Option                                                    | Use when                                                                     |
| --------------------------------------------------------- | ---------------------------------------------------------------------------- |
| **Monorepo** (one repo: `mobile/`, `admin/`, `supabase/`) | Same team, shared types/config, single CI. **Recommended** for this project. |
| **Multi-repo** (separate repos per app)                   | Different teams, different release cycles.                                   |

**Steps:**

- [ ] Create a Git repository (GitHub, GitLab, or Bitbucket).
- [ ] If monorepo: add root folders, e.g. `apps/mobile/`, `apps/admin/`, `packages/shared/` (optional), `supabase/` (migrations, config).
- [ ] Add a root `README.md` with repo overview and links to this doc.

### 1.2 Branching strategy

- [ ] **Main branch:** `main` (or `master`) — always deployable.
- [ ] **Feature work:** `feature/<short-name>` or `feat/<ticket-id>-short-name` from `main`.
- [ ] **Releases (optional):** `release/v1.0` if you version releases.
- [ ] Document in `CONTRIBUTING.md`: “Create a branch from `main`, open a PR to `main`.”

### 1.3 Remote collaboration basics

- [ ] **Protected `main`:** Require PR reviews and passing CI before merge.
- [ ] **Issue tracker:** Use GitHub/GitLab issues (or Jira/Linear) for tasks and bugs.
- [ ] **Labels:** e.g. `mobile`, `admin`, `backend`, `docs`, `priority`.

---

## 2. Local Development Environment

### 2.1 Prerequisites (document for all developers)

- [ ] **Node.js:** LTS (e.g. 20.x). Recommend **nvm** or **fnm** for consistency.
- [ ] **Package manager:** **pnpm** (recommended for monorepos) or npm/yarn — pick one and document.
- [ ] **Git:** Latest stable.
- [ ] **Mobile:** For Expo — no Xcode/Android Studio required for basic dev; for full builds, document Xcode (Mac) and Android Studio.
- [ ] **Supabase CLI:** `npm i -g supabase` (optional but useful for migrations and local Supabase).

### 2.2 One-time repo setup

- [ ] Clone repo: `git clone <repo-url> && cd <repo>`.
- [ ] Install dependencies: e.g. `pnpm install` at repo root (and/or in each app).
- [ ] Copy env template: e.g. `cp .env.example .env` (and per-app if needed).
- [ ] Add `.env` to `.gitignore`; never commit secrets.

### 2.3 Environment variables

- [ ] Create **`.env.example`** (and `apps/admin/.env.example`, `apps/mobile/.env.example` if separate) with:
  - Supabase: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY` (admin); Expo: `EXPO_PUBLIC_SUPABASE_URL`, `EXPO_PUBLIC_SUPABASE_ANON_KEY`.
  - Placeholders for any other keys (e.g. push, inbound email); no real secrets.
- [ ] Document in README or a short **SETUP.md**: “Get Supabase URL and anon key from the team lead or Supabase dashboard (dev project).”

### 2.4 Supabase: dev project vs local

- [ ] **Option A (simplest):** One **Supabase Cloud project** for “development” — all devs use same DB (with seed data and clear rules). Good for small teams.
- [ ] **Option B:** Each dev gets a **personal Supabase project** (free tier) and uses their own `.env`. Better isolation, more setup.
- [ ] **Option C:** **Supabase local** (`supabase start`) for full local stack. Document in SETUP.md if you use it.
- [ ] Store **migrations** in repo (e.g. `supabase/migrations/`) and run `supabase db push` or apply via dashboard; keep schema in version control.

### 2.5 Running the apps locally

- [ ] **Admin:** e.g. `pnpm --filter admin dev` or `cd apps/admin && pnpm dev` — dev server (Vite/Next) with hot reload.
- [ ] **Mobile:** `pnpm --filter mobile dev` or `cd apps/mobile && pnpm start` — Expo dev server; document “scan QR with Expo Go” or simulator.
- [ ] Add these commands to root `package.json` scripts and to README/SETUP.md.

---

## 3. Code Quality & Consistency

### 3.1 Linting and formatting

- [ ] **ESLint:** Root config (e.g. `eslint.config.js`) with shared rules; overrides per app (React, React Native, Node).
- [ ] **Prettier:** Root `.prettierrc` and `.prettierignore`; format on save in editor.
- [ ] **EditorConfig:** `.editorconfig` (indent, line endings) so all editors behave the same.

### 3.2 Pre-commit hooks

- [ ] **Husky + lint-staged:** On `git commit`, run ESLint and Prettier on staged files (and optionally typecheck).
- [ ] Ensures broken lint or format doesn’t get committed.

### 3.3 TypeScript

- [ ] Strict TypeScript in `tsconfig.json` for admin and mobile.
- [ ] Shared types (e.g. API or DB types) in `packages/shared` or a `types/` folder if monorepo.

### 3.4 Testing (baseline)

- [ ] **Unit:** Vitest or Jest for shared logic and critical paths; React Testing Library for admin components.
- [ ] **E2E (admin):** Playwright or Cypress; one smoke flow (e.g. login) is enough to start.
- [ ] Document how to run tests in README: `pnpm test`, `pnoe test:e2e`.

---

## 4. CI/CD Pipeline

### 4.1 Choose CI provider

| Provider                 | Good for                                     |
| ------------------------ | -------------------------------------------- |
| **GitHub Actions**       | GitHub repos; generous free tier; good docs. |
| **GitLab CI**            | GitLab repos; built-in.                      |
| **Bitbucket Pipelines**  | Bitbucket.                                   |
| **CircleCI / Buildkite** | More complex pipelines.                      |

**Recommended:** **GitHub Actions** if you use GitHub.

### 4.2 Pipeline stages (conceptual)

1. **On every PR (and push to `main`):**
   - Install deps, lint, typecheck, unit tests.
   - Build admin app (and fail if build breaks).
   - Optionally build mobile (Expo) or run Expo’s checks.

2. **On merge to `main` (or on tag):**
   - **Admin:** Deploy to preview or production (e.g. Vercel, Netlify, or static host).
   - **Supabase:** Apply migrations (manual or via CI with Supabase CLI + token); optional.
   - **Mobile:** Build with **EAS Build** (Expo Application Services) and submit to TestFlight/Play Store (or only build for internal testing).

### 4.3 GitHub Actions example layout

- [ ] **Workflow: PR checks** (e.g. `.github/workflows/ci.yml`):
  - Checkout, setup Node, cache pnpm (or npm).
  - `pnpm install --frozen-lockfile`
  - `pnpm run lint`
  - `pnpm run typecheck` (if you add a root script)
  - `pnpm run test`
  - `pnpm run build` (admin) and optionally `pnpm run build` (mobile via EAS or local build).

- [ ] **Workflow: Deploy admin** (e.g. `.github/workflows/deploy-admin.yml`):
  - Trigger: push to `main` (or manual).
  - Build admin, deploy to Vercel/Netlify (using their GitHub integration or CLI and secrets).

- [ ] **Workflow: Mobile build** (e.g. `.github/workflows/mobile.yml`):
  - Trigger: push to `main` or tag, or manual.
  - Use **EAS Build** (Expo): `eas build --platform all --non-interactive` with `EXPO_TOKEN` and optionally `SUPABASE_*` in GitHub Secrets.

### 4.4 Secrets management

- [ ] **CI secrets:** Store in GitHub (Settings → Secrets): `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` (only if CI needs it), `EXPO_TOKEN`, Vercel/Netlify tokens, etc.
- [ ] **Never** commit `.env` or real keys; use `.env.example` and docs for local dev.

### 4.5 Supabase migrations in CI (optional)

- [ ] If you want CI to apply migrations: create a **Supabase access token**, store as secret, run `supabase db push` or `supabase migration up` in a deploy job. Prefer applying migrations in a controlled way (e.g. release step) rather than on every push.

---

## 5. Deployment Targets (summary)

| Component                | Suggested hosting                      | CI deploys when                                                        |
| ------------------------ | -------------------------------------- | ---------------------------------------------------------------------- |
| **Admin portal**         | Vercel or Netlify                      | Push to `main` (or branch previews on PR)                              |
| **Supabase**             | Supabase Cloud                         | Migrations applied manually or via CI on release                       |
| **Mobile (iOS/Android)** | EAS Build → TestFlight / Play Internal | On tag or manual workflow; store credentials in EAS and GitHub Secrets |

---

## 6. Documentation for developers

- [ ] **README.md:** Repo overview, quick start (clone, install, env, run admin + mobile).
- [ ] **SETUP.md** (or section in README): Prerequisites, env vars, Supabase dev project, first run.
- [ ] **CONTRIBUTING.md:** Branching, PR process, code style, how to run tests and lint.
- [ ] **.env.example:** All required variable names and placeholder values; no secrets.

---

## 7. Checklist summary

**Repo & collaboration**

- [ ] Create Git repo (monorepo recommended).
- [ ] Protect `main`, require PRs and passing CI.
- [ ] Document branching in CONTRIBUTING.md.

**Local dev**

- [ ] Document Node, pnpm, Git, Supabase CLI (optional).
- [ ] Add `.env.example` and SETUP.md.
- [ ] Decide: shared dev Supabase project vs per-dev project vs local Supabase.
- [ ] Document “how to run admin” and “how to run mobile.”

**Code quality**

- [ ] ESLint + Prettier + EditorConfig.
- [ ] Husky + lint-staged for pre-commit.
- [ ] TypeScript strict; add unit (and optional E2E) tests.

**CI/CD**

- [ ] Add CI workflow: lint, typecheck, test, build admin (and optionally mobile).
- [ ] Add deploy workflow for admin (Vercel/Netlify).
- [ ] Add mobile build (EAS) and store secrets in CI.
- [ ] (Optional) Automate Supabase migrations in CI.

**Docs**

- [ ] README, SETUP.md, CONTRIBUTING.md, .env.example.

---

_You can implement these steps in order: repo first, then local setup and docs, then lint/format/hooks, then CI, then deploy workflows._
