---
paths: ["src/app/api/**", "src/server/**"]
---

# API conventions

- Ogni handler: validazione zod → auth check → business → response.
- Status code: 400 (validation), 401 (no auth), 403 (no perm), 404 (not found), 409 (conflict), 422 (business rule), 5xx (server).
- Mai esporre stack trace o messaggi DB al client. `toErrorResponse(e)` sanifica.
- Mai accettare ID utente da body — sempre da sessione.
- Rate-limit obbligatorio per endpoint pubblici (Upstash `Ratelimit.slidingWindow`).
- Log strutturato: `logger.info({ userId, route, durationMs }, "request handled")`.
- Idempotency-Key supportata per POST mutanti critici (pagamenti, side-effect esterni).
