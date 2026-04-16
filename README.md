# Low-Rejection Meeting Platform

Mutual-interest meeting platform: users register others’ work emails privately; a **match** occurs only when both have added each other. See **[REQUIREMENTS.md](./REQUIREMENTS.md)** for full product requirements.

## Monorepo layout

| Path               | Purpose                                                       |
| ------------------ | ------------------------------------------------------------- |
| `apps/mobile/`     | Member app — React Native (Expo) — _scaffold in Step 2_       |
| `apps/admin/`      | Admin portal — React (Vite or Next.js) — _scaffold in Step 2_ |
| `packages/shared/` | Optional shared TypeScript types / constants                  |
| `supabase/`        | Migrations and Supabase config                                |

## Prerequisites

- **Node.js 20 LTS** ([nodejs.org](https://nodejs.org) or `fnm` / `nvm-windows`)
- **pnpm** — `npm install -g pnpm` or `corepack enable && corepack prepare pnpm@latest --activate`
- **Git**

## Quick start

```bash
pnpm install
cp .env.example .env   # Windows: copy .env.example .env
```

Fill `.env` with your Supabase URL and anon key (see **[SETUP.md](./SETUP.md)**).

```bash
pnpm run lint
pnpm run format:check
```

## Documentation

| Doc                                                                                      | Description                  |
| ---------------------------------------------------------------------------------------- | ---------------------------- |
| [SETUP.md](./SETUP.md)                                                                   | Developer onboarding         |
| [CONTRIBUTING.md](./CONTRIBUTING.md)                                                     | Branches, PRs, code style    |
| [STEP-01-REPOSITORY-AND-DEV-ENVIRONMENT.md](./STEP-01-REPOSITORY-AND-DEV-ENVIRONMENT.md) | Detailed Step 1 instructions |
| [NEXT-STEPS.md](./NEXT-STEPS.md)                                                         | Roadmap after Step 1         |
| [DEV-ENVIRONMENT-AND-CICD.md](./DEV-ENVIRONMENT-AND-CICD.md)                             | CI/CD plan                   |
| [SUPABASE.md](./SUPABASE.md)                                                             | Backend stack notes          |
| [FRONTEND-TOOLS.md](./FRONTEND-TOOLS.md)                                                 | Mobile / admin tooling       |

## Scripts (root)

| Script                  | Description           |
| ----------------------- | --------------------- |
| `pnpm run lint`         | ESLint                |
| `pnpm run format`       | Prettier — write      |
| `pnpm run format:check` | Prettier — check only |

After `apps/mobile` and `apps/admin` exist, add `dev` scripts per app (see SETUP.md).

## License

Proprietary / TBD.
