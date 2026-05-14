---
name: scaffold-route
description: Genera un nuovo Next.js Route Handler (App Router) con validazione zod, auth check, error handling tipato, test colocato. Triggera quando l'utente chiede "aggiungi endpoint", "nuova API", "nuova route handler", "POST/GET /api/...".
---

## Procedura

1. Chiedi (se non specificato): path, metodi HTTP, auth richiesta (public/user/admin), payload shape.
2. Crea:
   - `src/app/api/<segment>/route.ts`
   - `src/app/api/<segment>/route.test.ts`
   - Se serve, schema in `src/lib/schemas/<segment>.ts`.
3. Template route.ts:

```ts
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { requireUser } from "@/lib/auth";
import { ApiError, toErrorResponse } from "@/lib/errors";

const Body = z.object({ /* TODO */ });

export async function POST(req: NextRequest) {
  try {
    const user = await requireUser(req);
    const parsed = Body.safeParse(await req.json());
    if (!parsed.success) throw new ApiError("validation", parsed.error.format(), 400);
    // TODO: business logic
    return NextResponse.json({ ok: true });
  } catch (e) {
    return toErrorResponse(e);
  }
}
```

4. Aggiungi test con `msw` per dipendenze esterne. Esegui `pnpm test` sul nuovo file.
5. Aggiorna OpenAPI/tRPC router se presente.

## Vincoli

- Mai endpoint senza auth check esplicito (anche `requireAnon()` se public).
- Mai `console.log` — usa `logger` da `@/lib/log`.
- Status code semantici (400 validation, 401 auth, 403 perms, 404 not found, 409 conflict, 422 business, 500 server).
