# Mobile app (members)

React Native with **Expo** and TypeScript (see [FRONTEND-TOOLS.md](../../FRONTEND-TOOLS.md)).

## Scaffold (when you start Step 2)

From the **repository root**:

```bash
pnpm create expo-app apps/mobile --template blank-typescript
```

Or follow the current Expo docs if the command differs. Then:

- Add this folder to the pnpm workspace (it should match `apps/*` in `pnpm-workspace.yaml`).
- Set `EXPO_PUBLIC_SUPABASE_URL` and `EXPO_PUBLIC_SUPABASE_ANON_KEY` in root `.env` or `apps/mobile/.env` per Expo’s env rules.

## Run

```bash
cd apps/mobile
pnpm start
```

Use Expo Go on a device or an emulator.
