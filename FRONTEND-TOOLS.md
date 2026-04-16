# Front-end development tools options

Overview of front-end options for this project: **native mobile apps** (iOS & Android) and **web admin portal**.

---

## 1. Mobile (iOS & Android)

| Option                      | Pros                                                        | Cons                                                              |
| --------------------------- | ----------------------------------------------------------- | ----------------------------------------------------------------- |
| **React Native**            | One codebase, JS/TS, huge ecosystem, Supabase has JS client | Some native modules; performance fine for chat/list UIs           |
| **Expo** (React Native)     | Easier setup, OTA updates, good for MVP                     | Fewer custom native tweaks until you "eject"                      |
| **Flutter** (Dart)          | One codebase, fast, consistent UI                           | Different language (Dart); Supabase via REST or community clients |
| **Native** (Swift + Kotlin) | Best performance, full platform APIs                        | Two codebases, more cost and time                                 |
| **.NET MAUI**               | C#, one codebase, Microsoft stack                           | Smaller ecosystem than RN/Flutter for this use case               |

**Practical choice for this project:** **React Native (with or without Expo)** — one codebase, TypeScript, and Supabase's JS client fits well. Flutter is a solid alternative if you prefer Dart.

---

## 2. Web admin portal

| Option                 | Pros                                                | Cons                                           |
| ---------------------- | --------------------------------------------------- | ---------------------------------------------- |
| **React** (Vite / CRA) | Huge ecosystem, Supabase client, many UI libs       | Many choices to make (routing, state, etc.)    |
| **Next.js** (React)    | SSR, API routes, good DX, easy deploy (Vercel etc.) | Heavier than a plain SPA if you don't need SSR |
| **Vue** (Vite)         | Simple, gentle learning curve, good docs            | Smaller ecosystem than React                   |
| **Svelte / SvelteKit** | Small bundle, fast, less boilerplate                | Smaller ecosystem                              |
| **Angular**            | Full framework, structure, enterprise common        | Steeper learning curve, more boilerplate       |

**Practical choice:** **React + Vite** or **Next.js** — both work well with Supabase; Next.js is handy if the admin will have many pages or you want API routes.

---

## 3. Build & tooling

| Tool           | Use                                                         |
| -------------- | ----------------------------------------------------------- |
| **Vite**       | Fast dev server and builds for React, Vue, Svelte.          |
| **Webpack**    | Classic bundler; still used by CRA, Next.js under the hood. |
| **esbuild**    | Very fast (often used inside Vite).                         |
| **TypeScript** | Recommended for both mobile and web for type safety.        |

---

## 4. UI / design

| Option                  | Use                                                                                                                       |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| **Tailwind CSS**        | Utility-first CSS; quick, consistent styling.                                                                             |
| **Component libraries** | **React:** MUI, Chakra, Radix, shadcn/ui. **React Native:** NativeBase, Tamagui, Paper. **Flutter:** Material, Cupertino. |
| **Figma**               | Design and handoff before coding.                                                                                         |

---

## 5. Other useful tools

- **Git** — version control.
- **ESLint + Prettier** — linting and formatting.
- **Jest / Vitest** — unit tests; **React Testing Library** for React.
- **Playwright or Cypress** — E2E tests for the admin portal.

---

## Summary recommendation

- **Mobile:** React Native (Expo) + TypeScript + Supabase JS client.
- **Admin:** React + Vite or Next.js + TypeScript + Supabase + Tailwind (and optionally a component library like shadcn/ui or MUI).
