# Migrations and Git workflow

Short reference for applying **Supabase migrations** to your hosted database and pushing **source changes** to GitHub.

---

## Update the database schema (new migrations)

**Prerequisites**

1. Repo root has a **`.env`** file (gitignored) with:

   `SUPABASE_DB_PASSWORD=<postgres password>`

   Use **Dashboard → Project Settings → Database** (the **postgres** user password), not the anon/service API keys.

2. This repo is **linked** to your Supabase project (stored under `supabase/.temp/`). First time or new clone:

   ```powershell
   pnpm db:link -- --project-ref <YOUR_PROJECT_REFERENCE_ID>
   ```

**Apply pending migrations**

From the **repository root**:

```powershell
pnpm db:push
```

- Confirm when prompted, **or** skip the prompt:

  ```powershell
  pnpm db:push -- --yes
  ```

- Add new SQL under **`supabase/migrations/`** using the CLI or copy an existing migration’s naming pattern (`YYYYMMDDHHMMSS_description.sql`).

**Why `pnpm db:push`?**

This project runs the Supabase CLI via **`scripts/run-supabase-with-env-password.mjs`**, which reads **`SUPABASE_DB_PASSWORD`** from **`.env`** and passes **`-p`** to the CLI so password-less `cli_login_postgres` is avoided (especially on Windows).

---

## Update GitHub

**Do not commit `.env`** — it is listed in **`.gitignore`** and must stay local.

From the **repository root**:

```powershell
git status
git add <paths-or-files>
git commit -m "Describe your change"
git push origin main
```

Use your real branch name instead of **`main`** if you work on another branch.

**Typical flow after editing migrations or code**

```powershell
git add .
git status
git commit -m "Your message"
git push origin main
```

Review **`git status`** before committing to ensure secrets (e.g. `.env`) do not appear under “Changes to be committed”.

---

## One-line checklist

| Goal                | Command                                                  |
| ------------------- | -------------------------------------------------------- |
| Push DB migrations  | `pnpm db:push` (from repo root, `.env` + linked project) |
| Push code to GitHub | `git push origin main` (after `git add` + `git commit`)  |
