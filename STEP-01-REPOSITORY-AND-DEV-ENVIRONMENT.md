# Step 1: Repository and Development Environment — Detailed Instructions

This guide walks you through **creating the Git repository**, **monorepo layout**, **documentation**, and **shared tooling** (ESLint, Prettier, EditorConfig, Husky, lint-staged) for the Low-Rejection Meeting Platform. It assumes **Windows 10/11** and **GitHub**; adapt hostnames and paths if you use GitLab/Bitbucket or macOS/Linux.

**Time estimate:** 1–2 hours for one person; add time for team onboarding (sharing repo URL and Supabase dev keys).

---

## Part A: Install prerequisites on your machine

### A1. Git

1. Download **Git for Windows** from https://git-scm.com/download/win
2. Run the installer. Recommended options:
   - **Default editor:** your choice (VS Code / Cursor is fine).
   - **PATH:** “Git from the command line and also from 3rd-party software”.
   - **Line endings:** “Checkout Windows-style, commit Unix-style” (`core.autocrlf=true`).
3. Open **PowerShell** or **Command Prompt** and verify:
   ```powershell
   git --version
   ```
4. **Configure your identity** (once per machine):
   ```powershell
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```
   Use the email you want on commits (often your work or GitHub noreply address).

### A2. Node.js (LTS)

You need **Node.js 20 LTS** (or current LTS from https://nodejs.org).

**Option 1 — Installer:** Download the Windows LTS `.msi` from nodejs.org and install. Verify:

```powershell
node --version
npm --version
```

**Option 2 — Version manager (recommended for teams):**

- **fnm** (fast): https://github.com/Schniz/fnm#windows  
  Or **nvm-windows**: https://github.com/coreybutler/nvm-windows/releases

After installing Node 20 LTS:

```powershell
node --version   # should show v20.x.x
```

### A3. pnpm (package manager)

The monorepo uses **pnpm** workspaces. Install pnpm globally:

```powershell
npm install -g pnpm
pnpm --version
```

If you prefer **Corepack** (ships with Node 16.13+):

```powershell
corepack enable
corepack prepare pnpm@latest --activate
pnpm --version
```

**Team rule:** Pick one package manager (pnpm) and document it in `SETUP.md` so everyone uses the same lockfile (`pnpm-lock.yaml`).

### A4. Editor: Cursor / VS Code

1. Install **Cursor** (or VS Code).
2. Recommended extensions (install from the Extensions view):
   - **ESLint**
   - **Prettier** (or use built-in format if you prefer)
   - **EditorConfig for VS Code**
3. Optional: enable **Format on Save** for Prettier (see your `update-cursor-settings` skill or Settings → search “format on save”).

### A5. GitHub account and authentication

1. Create or use a **GitHub** account.
2. Authenticate Git with GitHub:
   - **HTTPS:** use a **Personal Access Token** when prompted for password (GitHub → Settings → Developer settings → Personal access tokens).
   - **SSH:** generate a key (`ssh-keygen`), add the public key to GitHub → Settings → SSH keys, then clone with `git@github.com:...`.

---

## Part B: Create the remote repository on GitHub

### B1. New repository (web UI)

1. Log in to **https://github.com**.
2. Click **+** → **New repository**.
3. **Repository name:** e.g. `low-rejection-platform` or `meeting-platform`.
4. **Description:** optional (e.g. “Low-rejection mutual-interest meeting platform”).
5. **Visibility:** **Private** is typical until you open-source.
6. **Do not** add README, .gitignore, or license **if** you already have files locally you want to push (avoids merge conflicts). If the repo is empty, you can add these locally first, then push.
7. Click **Create repository**.

Copy the **HTTPS** or **SSH** clone URL shown on the next page.

### B2. Protect `main` (after first push)

After your first successful push:

1. Repo → **Settings** → **Branches** → **Add branch protection rule**.
2. Branch name pattern: `main`.
3. Enable:
   - **Require a pull request before merging** (optional but recommended once CI exists).
   - **Require status checks to pass** (add after you add GitHub Actions).
4. Save.

You can enable strict protection later; for solo work, you might skip until CI is ready.

---

## Part C: Initialize Git and connect the remote (local project folder)

These steps assume your project files live in a folder (e.g. `project04`). If this folder is **not** yet a Git repo:

### C1. Open terminal in the project root

```powershell
cd "c:\Users\georg\OneDrive\DEV\cursordev\project04"
```

(Adjust the path if your folder is elsewhere.)

### C2. Initialize Git

```powershell
git init
git branch -M main
```

### C3. Add the remote

Replace `YOUR_USER` and `YOUR_REPO` with your GitHub username and repo name:

```powershell
git remote add origin https://github.com/YOUR_USER/YOUR_REPO.git
```

For SSH:

```powershell
git remote add origin git@github.com:YOUR_USER/YOUR_REPO.git
```

Verify:

```powershell
git remote -v
```

### C4. First commit and push

```powershell
git add .
git status
git commit -m "chore: initial repo — docs and dev environment scaffold"
git push -u origin main
```

If the remote already has a README (from GitHub’s “add README” checkbox), you must pull first:

```powershell
git pull origin main --allow-unrelated-histories
# resolve any conflicts, then:
git push -u origin main
```

---

## Part D: Monorepo folder structure

Use a **single repository** with clear boundaries for mobile, admin, and Supabase:

```text
project-root/
├── apps/
│   ├── mobile/          # React Native (Expo) — member app
│   └── admin/           # React (Vite or Next.js) — admin portal
├── packages/
│   └── shared/          # optional: shared TypeScript types, constants
├── supabase/
│   ├── migrations/      # SQL migrations (create when you add Supabase CLI)
│   └── config.toml      # optional: from `supabase init`
├── .editorconfig
├── .env.example
├── .gitignore
├── .prettierignore
├── .prettierrc
├── eslint.config.mjs
├── package.json
├── pnpm-workspace.yaml
├── README.md
├── SETUP.md
├── CONTRIBUTING.md
├── REQUIREMENTS.md
└── ... (other docs)
```

### D1. Create folders

If they do not exist yet:

```powershell
mkdir apps\mobile, apps\admin, packages\shared, supabase\migrations -Force
```

### D2. Placeholder READMEs (optional)

In `apps/mobile/README.md`, note that the app will be created with Expo (see **SETUP.md**). Same for `apps/admin` with Vite/Next.js. This avoids empty folders confusing Git (Git does not track empty dirs; a `.gitkeep` or README fixes that).

---

## Part E: Root `package.json` and pnpm workspaces

### E1. `pnpm-workspace.yaml`

At the repo root, create `pnpm-workspace.yaml`:

```yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

### E2. Root `package.json`

- `"private": true` — prevents accidental publish to npm.
- `"packageManager"` — pins pnpm version for Corepack (optional but good for teams).
- `scripts`: `lint`, `format`, `prepare` (for Husky).

After files exist, run **once** at repo root:

```powershell
pnpm install
```

This creates `pnpm-lock.yaml`. **Commit the lockfile** so all developers get the same dependency versions.

> If this repo already contains `package.json` and `pnpm-workspace.yaml` but no `pnpm-lock.yaml` yet, run **`pnpm install`** once and commit the generated **`pnpm-lock.yaml`**. Do not commit `package-lock.json` (this project standardizes on pnpm; it is listed in `.gitignore`).

---

## Part F: Environment variables template

### F1. `.env.example` (root)

Create **`.env.example`** with **placeholder names only** — no real secrets:

```env
# Supabase (get from Supabase project → Settings → API)
# Mobile (Expo): use EXPO_PUBLIC_ prefix
EXPO_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
EXPO_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here

# Admin (Vite): use VITE_ prefix
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

When you scaffold `apps/mobile` and `apps/admin`, you can add **per-app** `.env.example` files if you prefer to keep env next to each app.

### F2. `.gitignore`

Ensure **`.env`**, **`.env.local`**, and **`.env.*.local`** are listed in `.gitignore` so secrets are never committed.

### F3. Local setup

Each developer copies the example and fills in values:

```powershell
copy .env.example .env
```

Edit `.env` with real keys (never commit `.env`).

---

## Part G: EditorConfig

Create **`.editorconfig`** at the repo root so every editor uses consistent indentation and line endings:

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

[*.md]
trim_trailing_whitespace = false
```

On Windows, Git’s `core.autocrlf` still helps; EditorConfig’s `lf` keeps commits consistent for CI/Linux.

---

## Part H: Prettier

### H1. `.prettierrc` (JSON)

Example:

```json
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "es5",
  "printWidth": 100
}
```

### H2. `.prettierignore`

Include at least:

```gitignore
node_modules
dist
build
.next
.expo
coverage
pnpm-lock.yaml
```

### H3. Scripts

In root `package.json`:

```json
"format": "prettier --write .",
"format:check": "prettier --check ."
```

Run:

```powershell
pnpm run format
```

---

## Part I: ESLint

### I1. Flat config (`eslint.config.mjs`)

Use **ESLint 9** flat config at the repo root. Start minimal; when you add `apps/mobile` and `apps/admin`, extend with React / React Native / TypeScript plugins.

### I2. Script

```json
"lint": "eslint ."
```

Run:

```powershell
pnpm run lint
```

### I3. Per-app ESLint (later)

After scaffolding Expo and Vite/Next, add an `eslint.config.mjs` inside each app **or** use root config with `ignores` and overrides for `apps/mobile` vs `apps/admin`.

---

## Part J: Husky and lint-staged

These run **before each commit** so broken formatting or lint errors are caught early.

### J1. Install dev dependencies

From repo root:

```powershell
pnpm add -D husky lint-staged
```

### J2. Enable Husky

```powershell
pnpm exec husky init
```

This adds a `prepare` script and `.husky/pre-commit`. Edit **`.husky/pre-commit`** to run lint-staged:

```sh
pnpm exec lint-staged
```

(On Windows, Husky runs with Git Bash or sh; the line above is standard.)

### J3. `lint-staged` in `package.json`

Add a top-level **`lint-staged`** key:

```json
"lint-staged": {
  "*.{md,css,json,yml,yaml}": "prettier --write",
  "*.{js,mjs,cjs,ts,tsx,jsx}": [
    "eslint --fix",
    "prettier --write"
  ]
}
```

Adjust globs as you add file types.

### J4. First commit with hooks

```powershell
git add .
git commit -m "chore: add eslint, prettier, husky"
```

Pre-commit should run Prettier/ESLint on staged files. If something fails, fix or adjust rules, then commit again.

---

## Part K: Documentation files

### K1. `README.md` (root)

Should include:

- One-sentence product description (link to `REQUIREMENTS.md`).
- **Prerequisites:** Node 20, pnpm, Git.
- **Quick start:** clone → `pnpm install` → copy `.env.example` → `SETUP.md` for full steps.
- Links to `SETUP.md`, `CONTRIBUTING.md`, `NEXT-STEPS.md`, `DEV-ENVIRONMENT-AND-CICD.md`.

### K2. `SETUP.md` (developer onboarding)

Include:

1. Install Git, Node 20 LTS, pnpm (link to Part A or repeat short version).
2. Clone: `git clone <url> && cd <repo>`.
3. `pnpm install`.
4. Copy `.env.example` to `.env` and ask the team lead for Supabase dev URL/key (or create your own Supabase project).
5. **When apps exist:** how to run `pnpm --filter mobile dev` and `pnpm --filter admin dev` (update after scaffolding).
6. Optional: **Supabase CLI** — `npm i -g supabase` and `supabase login` (for migrations later).

### K3. `CONTRIBUTING.md`

Include:

- **Branching:** create `feature/short-description` from `main`.
- **Pull requests:** open PR to `main`, describe changes, link issues.
- **Reviews:** at least one approval before merge (when team > 1).
- **Commits:** optional convention (e.g. Conventional Commits: `feat:`, `fix:`, `chore:`).
- **Before pushing:** `pnpm run lint` and `pnpm run format:check` (or rely on pre-commit).
- **Code style:** Prettier + ESLint; no secrets in commits.

### K4. Pin Node version (optional but recommended)

Create **`.nvmrc`** or **`.node-version`** with:

```text
20
```

Document in `SETUP.md`: “Use Node 20 (see `.nvmrc`).”

---

## Part L: Remote collaboration checklist

- [ ] **Invite collaborators:** GitHub repo → Settings → Collaborators (or use a GitHub Organization and teams).
- [ ] **Issues / projects:** Enable Issues; optionally GitHub Projects for backlog.
- [ ] **Labels:** `mobile`, `admin`, `supabase`, `docs`, `bug`, `enhancement`.
- [ ] **Slack/Discord:** channel for dev questions and sharing Supabase dev project access (never post service role keys in chat — use 1Password or similar).
- [ ] **Supabase:** one shared **development** project for early phase, or per-dev projects — document in `SETUP.md`.

---

## Part M: Verify everything

Run from repo root:

```powershell
pnpm install
pnpm run format:check
pnpm run lint
git add .
git commit -m "test: verify husky"   # should trigger lint-staged
```

If all succeed, Step 1 is complete.

---

## Part N: What comes next (Step 2)

After the repo and dev environment are stable:

1. Create the **Supabase** project and **schema** (see `NEXT-STEPS.md` Phase 1, item 2).
2. Scaffold **Expo** in `apps/mobile` and **Vite or Next.js** in `apps/admin`, then wire workspace package names and root scripts (`pnpm --filter ...`).

---

## Troubleshooting (Windows)

| Issue                           | What to try                                                                                       |
| ------------------------------- | ------------------------------------------------------------------------------------------------- |
| `pnpm` not found                | Restart terminal after `npm install -g pnpm` or run `corepack enable`.                            |
| Husky hooks don’t run           | Run `pnpm exec husky init` again; ensure `prepare` script exists in `package.json`.               |
| Line-ending warnings            | `git config core.autocrlf true`; keep `.editorconfig` `end_of_line = lf` for consistency in repo. |
| ESLint errors on config files   | Add those paths to `ignores` in `eslint.config.mjs`.                                              |
| Permission denied on `git push` | Use HTTPS + PAT, or fix SSH key and `ssh -T git@github.com`.                                      |

---

_This document pairs with the scaffold files in the repo (`package.json`, `pnpm-workspace.yaml`, etc.). If you started from an empty folder, copy the patterns above or use the committed scaffold as a template._
