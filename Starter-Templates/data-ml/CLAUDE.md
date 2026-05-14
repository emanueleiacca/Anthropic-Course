# <<TODO: project name>>

Progetto di analisi/ML: <<TODO: domain, e.g. churn modeling, marketing attribution>>.
Dataset principali: <<TODO: source + sensitivity level>>.

## Stack

- **Lang**: Python 3.12 (uv per env), R opzionale per stats
- **Core**: pandas/polars, numpy, scikit-learn, statsmodels
- **DL**: PyTorch (se applicabile)
- **Notebooks**: Jupyter via `uv run jupyter lab`; sincronizzati con `jupytext` (`.py` percent format come source-of-truth)
- **Warehouse**: BigQuery (preferito) o Snowflake — query via SDK ufficiale, mai credenziali in notebook
- **Tracking**: MLflow locale (`mlruns/`) o W&B
- **Viz**: matplotlib (statico), plotly (interattivo), great_tables (report)

## Layout

```
data/             # gitignored, salvo small samples
  raw/            # immutabile
  interim/        # working
  processed/      # feature-ready
notebooks/        # esplorazione, .py via jupytext
src/<pkg>/        # codice riusabile
  data/           # loaders, schemas
  features/       # transform deterministici
  models/         # train/eval
  viz/
reports/          # output HTML/PDF
sql/              # query parametrizzate
tests/
```

## Commands

```bash
uv sync                    # install deps
uv run jupyter lab         # notebooks
uv run pytest              # tests
uv run ruff check .        # lint
uv run ruff format .       # format
uv run mypy src/           # types (best-effort)
uv run jupytext --sync notebooks/*.ipynb   # round-trip .py <-> .ipynb
make report NB=churn       # render notebook -> HTML reports/
```

## Conventions

- **Notebooks NON committano output**: pre-commit hook `nbstripout`. Source-of-truth = `.py` percent.
- **Determinismo**: fissa `random_state=42` ovunque; documenta versione dataset (hash/snapshot date) nel notebook header.
- **No magic side-effect**: ogni cella che scrive su disco lo dichiara nel markdown precedente.
- **SQL parametrizzato** via `${var}` o `jinjasql`; mai f-string con valori utente.
- **Schema validation**: `pandera` o `pydantic` sui DataFrame in input/output di funzioni core.
- **Memoria**: dataset > 5GB → polars o `read_*` chunked; mai `.copy()` gratuiti su df grandi.
- **PII**: mai loggare colonne sensibili; usa `mask_pii()` helper.

## Workflow

- Branch per esperimento: `exp/<short-id>-<desc>`.
- Ogni run modello logga: params, metriche, dataset version, git SHA. MLflow tag obbligatori.
- Report finale = notebook eseguito top-to-bottom + HTML in `reports/`.
- Code review focus: correttezza statistica > stile.

## Path-scoped rules

- `notebooks/**` → @.claude/rules/notebook-discipline.md
- `sql/**` → @.claude/rules/sql-style.md
- `src/<pkg>/models/**` → @.claude/rules/model-eval.md

## Vedi anche

Template completo per agents/skills/hooks/rules: vedi `EXTENDED-TEMPLATE.md` in questa directory.
