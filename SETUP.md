# Developer setup

## 1. Prerequisites

- **Node.js 20** — see `.nvmrc`. Use [fnm](https://github.com/Schniz/fnm) or [nvm-windows](https://github.com/coreybutler/nvm-windows) if you manage multiple Node versions.
- **pnpm** — `npm install -g pnpm` or enable Corepack (see [README](./README.md)).
- **Git** — [Git for Windows](https://git-scm.com/download/win) or your OS package manager.

## 2. Clone and install

```bash
git clone <your-repo-url>
cd low-rejection-platform   # or your folder name
pnpm install
```

## 3. Environment variables

```bash
cp .env.example .env
```

On Windows PowerShell:

```powershell
copy .env.example .env
```

Edit `.env`:

- **`EXPO_PUBLIC_SUPABASE_*`** — for the mobile app (Expo).
- **`VITE_SUPABASE_*`** — for the admin app (Vite).

Get values from your team lead or from [Supabase](https://supabase.com) → Project → **Settings → API** (URL + `anon` `public` key). **Never commit `.env`** or the service role key.

## 4. Run apps (after scaffolding)

Mobile and admin apps are created in **Step 2** of [NEXT-STEPS.md](./NEXT-STEPS.md). Once they exist, typical commands:

```bash
pnpm --filter mobile start    # or package name from apps/mobile/package.json
pnpm --filter admin dev
```

Until then, you can still run repo-wide checks:

```bash
pnpm run lint
pnpm run format:check
```

## 5. Optional: Supabase CLI

For migrations and local Supabase:

```bash
npm install -g supabase
supabase login
```

See [SUPABASE.md](./SUPABASE.md) and [NEXT-STEPS.md](./NEXT-STEPS.md).

## 6. Git hooks

After `pnpm install`, **Husky** runs **lint-staged** on commit. If a commit fails, fix lint/format issues or ask the team before skipping hooks (`--no-verify` only when justified).

## More detail

Full walkthrough: **[STEP-01-REPOSITORY-AND-DEV-ENVIRONMENT.md](./STEP-01-REPOSITORY-AND-DEV-ENVIRONMENT.md)**.
