---
name: deploy-preview
description: Prepara branch per preview deploy su Vercel — verifica build locale, env vars, migrazioni pending, e apre PR con checklist. Triggera su "deploy preview", "apri PR", "pronto per review".
---

## Procedura

1. `git status` — lavora solo se branch pulito e non `main`.
2. Esegui in sequenza, ferma al primo errore:
   - `pnpm typecheck`
   - `pnpm lint`
   - `pnpm test`
   - `pnpm build`
3. Verifica migrazioni: `ls drizzle/ | tail -3`; se presenti file nuovi non taggati come applicati su staging → BLOCCA e segnala.
4. Verifica env: confronta `src/env.ts` con `.env.example`; se nuove var → aggiungi a `.env.example` e segnala "settare su Vercel".
5. `git push -u origin HEAD` (chiedi conferma).
6. `gh pr create` con body che include:
   - Summary (3 bullet)
   - Migrations: yes/no + nomi file
   - New env vars: lista
   - Test plan checklist
   - Rollback plan

## Vincoli

- Mai push se test/build falliscono.
- Mai push diretto su `main`.
- Se PR già esistente, aggiorna body invece di duplicare.
