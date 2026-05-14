# <<TODO: project name>>

App full-stack: <<TODO: 1-line description>>.
Audience: <<TODO: e.g. B2B SaaS, consumer, internal>>.

## Stack

- **Frontend**: Next.js 15 (App Router) + React 19 + TypeScript + Tailwind + shadcn/ui
- **Backend**: Next.js Route Handlers + tRPC (or `/api/*`) — server actions where idiomatic
- **DB**: Postgres 16 (Drizzle ORM), migrations in `drizzle/`
- **Cache/Queue**: Redis (Upstash) — sessions, rate-limit, BullMQ jobs
- **Auth**: <<TODO: NextAuth / Clerk / custom>>
- **Hosting**: <<TODO: Vercel / Fly / self-hosted>>
- **Observability**: Sentry + Vercel Analytics + structured logs (pino)

## Commands

```bash
pnpm dev               # dev server
pnpm build             # production build
pnpm test              # vitest run
pnpm test:e2e          # playwright
pnpm lint              # eslint + prettier check
pnpm typecheck         # tsc --noEmit
pnpm db:migrate        # apply drizzle migrations
pnpm db:studio         # drizzle studio
```

Run `pnpm typecheck && pnpm lint && pnpm test` before declaring work done.

## Conventions

- **Files**: `kebab-case.ts`; React components `PascalCase.tsx`; one component per file.
- **Imports**: absolute via `@/` alias; group: stdlib → external → internal → relative; no `default export` for utils.
- **Types**: `interface` for objects, `type` for unions; prefer `zod` schemas + `z.infer` over hand-written types at boundaries.
- **Errors**: never `throw new Error("string")` at API layer — use typed error classes in `src/lib/errors.ts`; return `Result<T,E>` for fallible domain code.
- **DB**: all queries in `src/db/queries/*`; never inline SQL in route handlers; every mutation goes through a migration.
- **Server vs Client**: `"use client"` only at leaf interactive components; data fetching server-side by default.
- **Secrets**: only in `process.env`, validated by `src/env.ts` (`@t3-oss/env-nextjs`). Never log secrets.
- **Tests**: colocated `*.test.ts`; e2e in `e2e/`; mock network with `msw`.

## Workflow

- Branch from `main`: `feat/<scope>-<short>`, `fix/<scope>-<short>`.
- Conventional Commits. Squash-merge. PR template enforced.
- Every PR: green CI (lint+typecheck+test+build) + 1 review + Vercel preview.
- DB migrations land in a dedicated PR, deployed before app code that depends on them.

## Path-scoped rules

- `src/app/api/**` → @.claude/rules/api-conventions.md
- `src/db/**` → @.claude/rules/db-safety.md
- `src/components/**` → @.claude/rules/ui-patterns.md
