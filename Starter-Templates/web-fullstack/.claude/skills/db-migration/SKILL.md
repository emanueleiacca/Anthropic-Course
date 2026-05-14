---
name: db-migration
description: Genera una migrazione Drizzle backward-compatible. Triggera su "aggiungi colonna", "rinomina", "nuovo indice", "cambia tipo colonna", "nuova tabella".
---

## Procedura

1. Leggi `src/db/schema.ts` per stato attuale.
2. Applica modifica allo schema TypeScript.
3. Esegui `pnpm drizzle-kit generate` per produrre SQL in `drizzle/`.
4. **Apri il file generato e ispezionalo**: cerca pattern pericolosi (`DROP`, `ALTER TYPE`, `NOT NULL` senza default).
5. Se rilevato pattern pericoloso → invoca sub-agent `db-migration-planner`.
6. Annota nel file SQL un commento iniziale `-- Reversible: yes/no; Estimated lock: <ms>; Backfill required: yes/no`.
7. NON eseguire `pnpm db:migrate`: chiedi conferma all'utente.

## Output

- File SQL committato in `drizzle/`.
- Snippet di rollback in commento.
- Update di `src/db/schema.ts`.
- Se cambia un tipo esposto: rigenerare i tipi consumer (`zod`, tRPC router).
