# Anatomia di una Skill: SKILL.md e frontmatter

Aggiornato: April 1, 2026 2:12 PM
Categoria: Claude Code
Corsi: Claude Code in Action, Intro to Agent Skills, Intro to Subagents
Stato: Da Approfondire

> 💬 Ogni Skill è una directory con un file obbligatorio [SKILL.md](http://SKILL.md) come manifesto: il frontmatter YAML definisce i metadati, i permessi e il comportamento di trigger, mentre la struttura directory (/scripts, /references, /assets) organizza le risorse per la disclosure progressiva.
> 

## Cos'è e perché importa

La Skill non è solo un file di testo con istruzioni: è un pacchetto strutturato con metadati che controllano quando viene attivata, quali permessi ha, come si integra con il sistema di subagent, e quali risorse aggiuntive può utilizzare. Capire la struttura tecnica di una Skill è il prerequisito per progettarne di affidabili: una Skill con descrizione vaga non viene mai attivata; una Skill con allowed-tools mal configurato richiede conferme manuali continue; un [SKILL.md](http://SKILL.md) di 2000 righe degrada la qualità delle risposte del modello. *(da Introduction to Agent Skills — Intro to Agent Skills)*

## Spiegazione

### Il frontmatter YAML: i campi e il loro impatto

Il frontmatter YAML è racchiuso tra i delimitatori `---` all'inizio del file [SKILL.md](http://SKILL.md). Ogni campo ha un effetto preciso e documentato sul comportamento della Skill. *(da Introduction to Agent Skills — Intro to Agent Skills)*

Il campo `name` è l'identificatore unico in formato kebab-case, massimo 64 caratteri, senza termini riservati come `anthropic` o `claude`. La forma gerundiva è preferita per nomi che indicano azioni continue: `processing-pdfs` invece di `pdf-processor`.

Il campo `description` è il componente più critico per la scoperta. Claude scansiona questo campo per decidere se caricare la Skill in risposta al task corrente. Una descrizione efficace specifica sia cosa fa la Skill sia quando usarla, includendo frasi trigger esplicite. Il limite è 250 caratteri: oltre questa soglia la descrizione viene troncata nell'indice. Strutturarla come "Usa quando l'utente menziona [lista di trigger specifici]..." è il pattern più affidabile per evitare under-triggering.

Il campo `allowed-tools` pre-approva l'uso di determinati tool mentre la Skill è attiva, eliminando la necessità di permessi manuali per ogni operazione. È possibile usare wildcard: `Bash(git *)` consente solo comandi git, `Bash(npm *)` solo comandi npm. È un meccanismo di sicurezza oltre che di comodità.

Il campo `disable-model-invocation` a `true` impedisce a Claude di attivare la Skill autonomamente: diventa disponibile solo tramite invocazione esplicita dell'utente con uno slash command. Il campo `user-invocable` a `false` fa l'opposto: nasconde la Skill dal menu degli slash command, rendendola una capacità di background che solo Claude può attivare internamente. Il campo `context: fork` indica che la Skill deve essere eseguita in un contesto di subagent separato, essenziale per workflow che generano molto output che non deve inquinare la conversazione principale.

### Esempio di frontmatter completo

```yaml
---
name: processing-financial-reports
description: >
  Usa quando l'utente chiede di analizzare report finanziari, bilanci,
  P&L, o documenti contabili. Trigger: 'bilancio', 'P&L', 'fatturato',
  'EBITDA', 'report finanziario'.
allowed-tools:
  - Read
  - Bash(python *)
  - Bash(node *)
disable-model-invocation: false
user-invocable: true
context: fork
---
```

### Struttura della directory: /scripts, /references, /assets

Il file [SKILL.md](http://SKILL.md) è l'unico elemento obbligatorio, ma una Skill professionale è organizzata in una struttura di directory che supporta la disclosure progressiva. *(da Introduction to Agent Skills — Intro to Agent Skills)*

La directory `/scripts` contiene file eseguibili (Python, Bash, Node.js) che la Skill può lanciare tramite il tool Bash. L'esecuzione degli script non consuma token: solo l'output testuale entra nel contesto. La directory `/references` contiene documentazione estesa — guide API, manuali di procedure, specifiche tecniche — che Claude legge solo se istruito a farlo o se ritiene necessario approfondire un dettaglio. Un manuale di migliaia di righe ha impatto zero sulla finestra di contesto finché non viene richiesto. La directory `/assets` è destinata a file non testuali: template di documenti, icone, immagini di riferimento da usare come input o output.

### Skill con fork vs Subagent con campo skills: differenza operativa

Il corso Intro to Subagents chiarisce la differenza tra due approcci all'esecuzione isolata. Una Skill con `context: fork` viene eseguita in un contesto di subagent separato — il system prompt è determinato dal tipo di agente, le risorse includono il [CLAUDE.md](http://CLAUDE.md) del progetto. È il meccanismo corretto per isolare l'esecuzione di una Skill singola senza definire un agente completo. *(da Introduction to SubAgents — Intro to Subagents)*

Un Subagent con il campo `skills` nel frontmatter è un agente completo in `.claude/agents/` che precarica integralmente le Skills elencate all'avvio — senza disclosure progressiva — insieme al [CLAUDE.md](http://CLAUDE.md). È il meccanismo corretto per un agente specializzato con un insieme fisso di competenze sempre disponibili. La scelta dipende dal grado di specializzazione richiesto: fork per isolare una Skill singola, subagent con campo skills per un agente multi-competenza riutilizzabile.

### Il pattern Socratic Questioning per task complessi

Il corso Claude Code in Action introduce un pattern per Skills che devono produrre output complessi come PRD o specifiche tecniche. Invece di generare immediatamente l'output, il pattern prevede che Claude ponga domande chiarificatrici su dimensioni specifiche prima di procedere: chiarezza del problema, vincoli tecnici, criteri di successo, pubblico di destinazione. Solo dopo aver ricevuto queste risposte, la Skill genera il documento. Il risultato finale è molto più allineato alle reali necessità perché il modello ha esplicitato i presupposti invece di inferirli. *(da Claude Code in Action — Claude Code in Action)*

### Risoluzione dei conflitti di trigger e collisioni di naming

In ambienti con molte Skills installate possono verificarsi due tipi di problemi. Le collisioni di nomi sono risolte da una gerarchia di precedenza: le Skills enterprise sovrascrivono quelle personali, che sovrascrivono quelle di progetto. I problemi di trigger sono più sottili: la Skill esiste ma Claude non la attiva perché la descrizione è troppo generica. La soluzione è includere nella descrizione liste di trigger espliciti — termini tecnici che l'utente userebbe — invece di descrizioni astratte. *(da Introduction to Agent Skills — Intro to Agent Skills)*

## Esempi concreti

Una struttura di directory completa per una Skill di analisi KPI:

```
skills/kpi-analysis/
├── SKILL.md              # Manifesto + istruzioni principali
├── scripts/
│   ├── extract_kpis.py   # Estrazione KPI da CSV
│   └── validate_data.py  # Validazione schema dati
├── references/
│   ├── kpi-taxonomy.md   # Definizioni e formule dei KPI
│   └── reporting-guide.md # Standard di reportistica aziendale
└── assets/
    └── report-template.xlsx # Template Excel per il report finale
```

*(da Introduction to Agent Skills — Intro to Agent Skills)*

## Errori comuni e cosa evitare

L'errore più frequente è scrivere una descrizione troppo generica che non attiva mai la Skill. "Aiuta con i file" non è una descrizione operativa: non specifica il tipo di file, il tipo di operazione, né il contesto. Una descrizione efficace è specifica e include termini che l'utente userebbe naturalmente. *(da Introduction to Agent Skills — Intro to Agent Skills)*

Un secondo errore è creare file [SKILL.md](http://SKILL.md) molto lunghi. Oltre le 500 righe, la qualità dell'attenzione del modello sul contenuto degrada: le istruzioni verso la fine vengono rispettate con meno accuratezza. La soluzione è tenere [SKILL.md](http://SKILL.md) conciso e spostare i dettagli in `/references`.

Un terzo errore riguarda i riferimenti ai file: se [SKILL.md](http://SKILL.md) istruisce Claude a leggere `references/api-guide.md` ma il file non esiste o il percorso non è corretto, il modello restituisce un errore di tool use. La struttura delle directory deve essere speculare a quanto dichiarato nelle istruzioni.

## Connessioni ad altri topic

Questo topic è la specifica tecnica di **Agent Skills in Claude Code** (il framework generale), collegato a **Context Window e Token** (la disclosure progressiva come strategia di gestione del contesto), a **Sicurezza nei sistemi agentici** (allowed-tools come meccanismo di sicurezza) e a **Pattern di workflow agentici** (le Skills come unità riutilizzabili nei workflow agentici).