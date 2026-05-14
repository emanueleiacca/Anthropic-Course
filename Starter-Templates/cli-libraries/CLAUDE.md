# <<TODO: library/CLI name>>

<<TODO: 1-line value prop>>.
Distribuito come: <<TODO: npm package / PyPI / cargo crate / standalone binary>>.

## Stack

- **Lang**: <<TODO: TypeScript 5.x | Python 3.12 | Rust 1.80+>>
- **Runtime target**: <<TODO: Node 20+, Bun; Python 3.10+; Rust stable>>
- **Build**: <<TODO: tsup/unbuild | hatchling | cargo>>
- **Test**: <<TODO: vitest | pytest | cargo test + insta>>
- **Docs**: typedoc / mkdocs / rustdoc; README come quickstart unico
- **Release**: changesets (TS) / hatch + twine (Py) / cargo-release (Rust)

## Public API contract

- API pubblica documentata in `src/index.ts` (`README.md` "API" section è source-of-truth user-facing).
- Breaking change = major bump. Vedi `.claude/rules/api-stability.md`.
- Ogni symbol pubblico ha: TSDoc/docstring + esempio + test.

## Commands

```bash
pnpm build             # bundle dist/
pnpm test              # vitest --run
pnpm lint
pnpm typecheck
pnpm docs              # typedoc -> docs/
pnpm changeset         # registra change set
```

(Equivalenti Python: `uv run pytest`, `uv run ruff`, `uv run mkdocs serve`, `uv build`.)
(Equivalenti Rust: `cargo test`, `cargo clippy -- -D warnings`, `cargo doc --no-deps`, `cargo release`.)

## Conventions

- **Zero deps** preferito; ogni dep runtime giustificata in PR.
- **Tree-shakeable**: named export, no side-effect in module top-level, `sideEffects: false` in package.json.
- **Errori tipizzati**: subclassi di `LibError` con `code` string-literal; mai eccezioni anonime.
- **CLI**: comandi via Commander.js / Typer / clap; `--help` deve essere autosufficiente.
- **Output CLI**: machine-readable opt-in (`--json`); umano default con spinner solo se stderr è TTY.
- **Cross-platform**: testato su Linux + macOS + Windows in CI.
- **Logging libreria**: silenziosa di default; espone hook (`onWarn`, `debug` callback). Mai `console.log` da lib code.

## Workflow

- Branch: `feat/`, `fix/`, `docs/`, `chore/`.
- Ogni PR utente-facing richiede un changeset (`pnpm changeset`).
- Release: tag pushato su `main` → CI pubblica → GitHub Release con CHANGELOG auto.
- SemVer rigoroso. Deprecation: 1 minor di warning prima di rimozione.

## Path-scoped rules

- `src/**/*.ts` → @.claude/rules/api-stability.md
- `src/cli/**` → @.claude/rules/cli-ux.md
- `tests/**` → @.claude/rules/testing-discipline.md

## Vedi anche

Template completo per agents/skills/hooks/rules: vedi `EXTENDED-TEMPLATE.md` in questa directory.
