---
paths: ["src/db/**", "drizzle/**"]
---

# DB safety

- Schema source-of-truth: `src/db/schema.ts`. Mai modifiche manuali al DB.
- Query solo via Drizzle; no SQL raw eccetto `sql.raw` con valori parametrizzati.
- Ogni `.where()` su tabelle multi-tenant include `eq(table.orgId, ctx.orgId)`.
- Indici su tutte le FK e su colonne usate in `WHERE`/`ORDER BY` frequenti.
- Migrazioni: vedi sub-agent `db-migration-planner` per cambi non-additivi.
- Connessione: usa pool singleton da `src/db/client.ts`; mai `new Pool()` nei handler.
- Soft delete preferito a hard delete per entità utente-facing (`deletedAt timestamp`).
