# Knowledge Base Operativa — Anthropic Academy

Questo file sintetizza tutto il corso Anthropic in un insieme di principi e workflow
operativi. Claude legge questo file automaticamente ad ogni sessione e lo usa come guida
per massimizzare le performance del progetto dell'utente.

---

## Metodologia di base: Framework 4D

Prima di ogni task, applicare questo schema mentale:

| Pilastro | Domanda chiave | In pratica |
|----------|---------------|------------|
| **Delegation** | Ho pianificato prima di agire? | Scomponi il task in sotto-passi. Non eseguire senza un piano. |
| **Description** | La comunicazione è precisa e tecnica? | Usa XML tag, specifica formato output, fornisci esempi. |
| **Discernment** | Ho valutato criticamente l'output? | Verifica risultati, cerca allucinazioni, usa Reasoning Audit. |
| **Diligence** | Ho integrato il lavoro nel sistema? | Aggiorna CLAUDE.md, versiona, mantieni il contesto pulito. |

---

## Prompting — Principi operativi

### Struttura di ogni prompt efficace

```
1. Role/Persona     → Chi è Claude in questo task?
2. Context          → Cosa sa già? Cosa è rilevante?
3. Objective        → Cosa deve produrre ESATTAMENTE?
4. Format           → Quale struttura deve avere l'output?
5. Examples         → Mostra il pattern atteso (few-shot)
```

### Regole pratiche

- **Istruzioni positive**, mai negative: "rispondi in JSON" non "non rispondere in testo libero"
- **XML tag** per separare sezioni logiche: `<context>`, `<task>`, `<examples>`, `<output>`
- **Progressive disclosure**: non sovraccaricare il prompt, aggiungi contesto solo quando serve
- **Effort fallback** (Claude 4): se la risposta non è buona, aggiungi "Pensa a fondo prima di rispondere"
- **System prompt** per istruzioni stabili e persistenti — non ripetere nelle richieste

### Chain-of-Thought e Reasoning

- Usa `<thinking>` tag per ragionamento esplicito su task complessi
- **Extended Thinking** (Claude 3.7+): `budget_tokens` per controllare profondità
- Evita over-prompting: non chiedere "spiega passo passo" se l'output deve essere diretto
- Per task ad alta precisione: chiedi a Claude di identificare le proprie incertezze

### Few-Shot

- Esempi diversi tra loro per evitare vincoli impliciti
- Genera dataset di test con Opus, valida con Haiku per efficienza di costo

---

## Scelta del modello giusto

| Modello | Usa quando... | Costo relativo |
|---------|--------------|----------------|
| **Claude Opus 4** | Ragionamento profondo, architettura, alta posta in gioco | Alto |
| **Claude Sonnet 4** | Reference point pratico, produzione standard | Medio |
| **Claude Haiku 4.5** | Volume alto, task semplici, valutazione/classificazione | Basso |
| **Claude 3.7** | Hybrid reasoning con Extended Thinking | Medio-Alto |

**Strategia:** Usa Opus per progettazione e generazione dataset di test. Usa Haiku per
valutazioni automatiche e task ripetitivi. Sonnet per il lavoro quotidiano.

---

## API — Best practice tecniche

### Struttura base Messages API

```python
response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=8096,
    system="...",          # Prompt stabile → candidato per caching
    messages=[...]
)
```

Sempre: traccia `usage.input_tokens`, `usage.output_tokens`, `stop_reason`.

### Prompt Caching — Riduzione costi fino all'80%

Applica `cache_control` su tutto ciò che è stabile tra chiamate:

```python
{"type": "text", "text": "...", "cache_control": {"type": "ephemeral"}}
```

- Cache standard: 5 minuti
- Cache estesa: 1 ora
- **Ordine critico**: system prompt → documenti di riferimento → storico conversazione → nuova richiesta
- Combina con Batch API per task non urgenti (50% sconto aggiuntivo)

### Streaming

- Usa Server-Sent Events per UX reattiva (TTFT basso)
- Gestisci `stop_reason` nel flusso: `end_turn`, `max_tokens`, `tool_use`
- Implementa retry con exponential backoff per errori di rete

### Tool Use — Ciclo a 4 fasi

```
1. Define   → Schema JSON dei tool disponibili
2. Invoke   → Claude decide quale tool usare (stop_reason = tool_use)
3. Execute  → Il client esegue il tool reale
4. Return   → Risultato torna a Claude per continuare
```

Regole tool:
- Nomi descrittivi e inequivocabili
- Un tool = una responsabilità (non tool tuttofare)
- Consolida tool simili per ridurre overhead cognitivo
- Valida gli output dei tool prima di passarli avanti

### Gestione errori

```python
# Pattern exponential backoff
for attempt in range(4):
    try:
        response = client.messages.create(...)
        break
    except RateLimitError:
        time.sleep(2 ** attempt)
```

Interpreta sempre `stop_reason` prima di procedere.

---

## Gestione del contesto

### Limiti operativi da rispettare

| Soglia | Azione consigliata |
|--------|-------------------|
| 0–50% finestra | Zona ottimale |
| 75–85% | Avvia Context Compaction |
| 90%+ | Critico — reset o fork sessione |
| Oltre 150k token | Context rot: le istruzioni iniziali si degradano |

### Principio JIT (Just-In-Time Context)

Carica solo il contesto rilevante al task corrente. Non caricare tutto all'inizio.
Più contesto non è meglio — è diluizione dell'attenzione.

### Compounding Context (pattern per memoria persistente)

Mantieni questi tre file nella root del progetto:

```
context.md      → Stato del progetto, decisioni prese, architettura
brandvoice.md   → Tono, stile, vincoli comunicativi
workingstyle.md → Come vuoi che Claude lavori con te (formato, verbosità, ecc.)
```

Claude li ricarica all'inizio di ogni sessione. Aggiornali dopo ogni sessione produttiva.

---

## Workflow agentici

### 5 Pattern fondamentali

| Pattern | Quando usarlo |
|---------|--------------|
| **Prompt Chaining** | Task con fasi sequenziali definite |
| **Routing** | Input diversi → specialisti diversi |
| **Parallelization** | Sotto-task indipendenti, eseguibili in parallelo |
| **Orchestrator-Workers** | Coordinatore centrale + worker specializzati |
| **Evaluator-Optimizer** | Loop iterativo: genera → valuta → migliora |

### Loop agentici — Livelli

```
L1 Inner Loop   → Tool use singolo (file read, API call)
L2 Task Loop    → Sequenza di tool per completare un task
L3 Meta Loop    → Coordinamento multi-agente, pianificazione strategica
```

**Attenzione**: la probabilità di errore si accumula. Task a 10 passi con 95% accuratezza
per passo = 60% di successo complessivo. Aggiungi checkpoint e validazione.

### Coordinator-Worker

- Il Coordinator mantiene la strategia, non esegue
- I Worker operano in contesti puliti e specializzati
- Comunicazione via output strutturato (JSON, XML)
- Ogni Worker ha scope limitato e definito

### Subagent SDK

```python
# Stateless (automation)
response = await query(prompt=..., options=ClaudeAgentOptions(...))

# Stateful (conversazione)
client = ClaudeSDKClient(...)
response = await client.query(...)
```

---

## Claude Code — Workflow ottimale

### Architettura delle sessioni

- **Chat tab**: ragionamento puro, pianificazione, domande
- **Cowork tab**: agente async con VM isolata, per task lunghi
- **Code tab**: integrazione filesystem, per coding diretto

### CLAUDE.md come cervello del progetto

Mantieni questo file aggiornato. È l'unico modo per dare a Claude memoria persistente
senza overhead di token. Include:
- Architettura del progetto
- Comandi chiave (build, test, deploy)
- Decisioni prese e loro motivazione
- Vincoli e convenzioni

### Skills — Quando crearle

Crea una Skill quando un workflow viene ripetuto più di 2-3 volte.

```yaml
# Frontmatter SKILL.md
name: nome-skill
description: "trigger semantico per Claude"
allowed-tools: [Read, Write, Bash]
user-invocable: true
```

3 livelli di disclosure: metadata → istruzioni → risorse full.

### Hooks — Automazione eventi

| Hook | Uso tipico |
|------|-----------|
| `PreToolUse` | Valida parametri, blocca azioni pericolose |
| `PostToolUse` | Azioni conseguenti, logging |
| `SubagentStop` | QA automatico sull'output |
| `SessionStart` | Carica contesto, ripristina stato |
| `UserPromptSubmit` | Pre-processing della richiesta |

### MCP — Integrazioni ad alto valore

Aggiungi MCP server per: GitHub (issues/PR), database (PostgreSQL/BigQuery),
browser (Playwright per test UI), monitoring (Sentry).

```bash
claude mcp add nome-server -- comando-server
```

---

## Evaluation-Driven Development

Ogni feature/modifica importante deve avere un ciclo di valutazione:

```
1. Genera dataset di test (usa Opus)
2. Definisci criteri di valutazione (model-based o deterministici)
3. Implementa
4. Valuta (usa Haiku per costo)
5. Itera fino a soglia soddisfacente
6. Integra valutazione come regression test
```

Non rilasciare feature senza sapere quanto bene funzionano.

---

## Sicurezza nei sistemi agentici

- **Privilege minimization**: ogni agente ha solo i permessi che servono
- **Human-in-the-loop** per azioni irreversibili (delete, push, pagamenti)
- **Defender Hooks** contro prompt injection via tool output
- **Gerarchia permessi**: Deny > Ask > Allow (default conservativo)
- **Git Worktree isolation** per operazioni rischiose su codice
- Valida input con schema (Pydantic) ai confini del sistema
- Non passare credenziali nei prompt — usa variabili d'ambiente

---

## Checklist per iniziare un nuovo progetto

- [ ] Crea/aggiorna `CLAUDE.md` con architettura e comandi chiave
- [ ] Crea `context.md`, `brandvoice.md`, `workingstyle.md`
- [ ] Scegli il modello giusto per ogni parte del workflow
- [ ] Identifica i contenuti statici da mettere in prompt caching
- [ ] Definisci i tool con nomi chiari e scope singolo
- [ ] Pianifica il pattern agentico (quale dei 5 si applica?)
- [ ] Imposta ciclo di evaluation prima di implementare
- [ ] Configura hooks per automazione e sicurezza

---

## Riferimenti rapidi

- Pattern agentici: `Topics/Agents-MCP/Agent Patterns/`
- API mechanics: `Topics/API-Tools/Claude API/`
- Prompt design: `Topics/Prompting/`
- Claude Code: `Topics/Claude Code/`
- Sicurezza: `Topics/Ethics-Safety/`
