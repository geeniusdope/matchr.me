# Contributing

## Branching

- **`main`** — default branch; should stay deployable.
- **Feature branches** — create from `main`, e.g. `feature/match-notification` or `feat/123-add-interest-list`.
- Open a **pull request** into `main` when ready for review.

## Pull requests

- Describe what changed and why.
- Link issues or tasks when applicable.
- Keep PRs focused (one feature or fix when possible).
- **Require review** before merging when more than one developer is on the project (enable branch protection on GitHub).

## Commits

Optional: use [Conventional Commits](https://www.conventionalcommits.org/) prefixes:

- `feat:` — new feature
- `fix:` — bug fix
- `chore:` — tooling, config, deps
- `docs:` — documentation only

## Before you push

```bash
pnpm run lint
pnpm run format:check
```

Pre-commit hooks run **lint-staged** (Prettier + ESLint on staged files). Fix failures rather than using `--no-verify` unless there is a documented exception.

## Secrets

- **Never** commit `.env`, API keys, or Supabase **service role** keys.
- Use `.env.example` for variable **names** only.

## Code style

- **Prettier** — formatting (see `.prettierrc`).
- **ESLint** — linting (see `eslint.config.mjs`). App-specific rules may be added under `apps/` later.

## Questions

Use your team chat or GitHub Discussions/Issues as agreed by the project.
