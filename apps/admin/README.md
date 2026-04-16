# Admin portal

Web app with **React**, **Vite** or **Next.js**, and TypeScript (see [FRONTEND-TOOLS.md](../../FRONTEND-TOOLS.md)).

## Scaffold (when you start Step 2)

From the **repository root**, e.g. Vite + React + TS:

```bash
pnpm create vite apps/admin --template react-ts
cd apps/admin
pnpm install
```

Configure `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` (see root `.env.example`).

## Run

```bash
cd apps/admin
pnpm dev
```
