---
paths: ["src/components/**", "src/app/**/*.tsx"]
---

# UI patterns

- Default: Server Component. `"use client"` solo se il componente usa hooks browser, event handler, o stato.
- Composizione > prop drilling: usa children e slot pattern.
- Form: react-hook-form + zod resolver; mai useState per form complessi.
- Loading: Suspense + skeleton; mai spinner globali.
- Error: `error.tsx` boundary per ogni segment route critico.
- Accessibility: ogni interactive ha label/aria; test con axe in e2e.
- Styling: Tailwind utility-first; `cn()` helper per condizionali; no inline style salvo dimensioni dinamiche.
- shadcn/ui per primitive: non re-implementare Button, Dialog, etc.
