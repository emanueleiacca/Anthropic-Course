# Subagents e task delegation

Aggiornato: April 1, 2026 9:23 AM
Categoria: Agents & MCP
Corsi: AI Fluency, Claude 101, Intro to Agent Skills, Intro to Claude Cowork, Intro to Subagents
Stato: Da Approfondire

> 💬 Delegare task a subagenti specializzati non è solo una questione di scalabilità: è una decisione architetturale che migliora la precisione, facilita il debugging e permette di bilanciare il costo computazionale tra modelli diversi.
> 

## Cos'è e perché importa

Un agente singolo che cerca di fare tutto — pianificare, eseguire, verificare, documentare — opera con un prompt di sistema necessariamente vago e un contesto che cresce in modo incontrollato man mano che il task progredisce. Il pattern Coordinator-Worker risolve questo problema distribuendo le responsabilità: un agente coordinatore mantiene la visione strategica, agenti worker eseguono compiti specifici in contesti puliti e focalizzati. *(da Claude 101 — Claude 101)*

## Spiegazione

### Il coordinatore: visione d'insieme e orchestrazione

Il coordinatore è l'agente che interagisce direttamente con l'utente, mantiene la storia del progetto e decide quale worker invocare per ogni sotto-task. Il suo prompt di sistema deve essere ampio abbastanza da coprire tutti i domini del progetto, ma non così dettagliato da diventare rumoroso. Il coordinatore non esegue — delega, monitora e aggrega. *(da Claude 101 — Claude 101)*

### I worker: specializzazione e affidabilità

Ogni worker ha un prompt di sistema estremamente focalizzato su un singolo dominio: scrittura di unit test, analisi di sicurezza, refactoring di codice legacy, generazione di documentazione. Questa focalizzazione produce due vantaggi concreti: il modello lavora con meno "rumore" nel contesto e produce risultati più precisi, e il comportamento del worker è più prevedibile e quindi più facile da testare. *(da Claude 101 — Claude 101)*

I worker possono girare su modelli diversi dal coordinatore. Task semplici e ripetitivi possono girare su Claude Haiku, riducendo significativamente il costo complessivo dell'architettura senza impattare la qualità dei risultati.

### La motivazione del contesto pulito

Il corso AI Fluency aggiunge una prospettiva importante che va oltre l'efficienza: mantenere il contesto della conversazione principale pulito e focalizzato. Ogni task delegato a un sub-agente porta con sé il proprio contesto locale — i file rilevanti, le istruzioni specifiche, la history dell'operazione — senza appesantire il contesto del coordinatore con informazioni irrilevanti per la visione d'insieme. *(da AI Fluency — AI Fluency)*

Il coordinatore mantiene alta la propria capacità di attenzione sui task strategici perché il suo contesto non è ingombro dai dettagli operativi di ogni sotto-task. È esattamente l'opposto del Prompt Bloat: invece di accumulare contesto irrilevante, lo si distribuisce dove è effettivamente utile.

### Comunicazione strutturata tra agenti

Per rendere l'architettura Coordinator-Worker robusta, la comunicazione tra agenti deve essere strutturata. I worker devono restituire output in formato deterministico — JSON è il più comune — includendo sempre un campo di stato che segnali successo o fallimento. Il coordinatore non deve mai assumere che l'output di un worker sia valido senza verificarlo: la validazione prima di procedere è la differenza tra un sistema che si rompe in modo comprensibile e uno che produce risultati errati in silenzio. *(da Claude 101 — Claude 101)*

### Plugin come unità di composizione di Skills, MCP e Slash Commands

Il corso Intro to Claude Cowork introduce il concetto di Plugin come livello di astrazione superiore alla singola Skill o al singolo server MCP. Un Plugin raggruppa in un unico pacchetto coerente le Skills Markdown con le istruzioni di dominio, la configurazione dei connettori MCP per i servizi necessari, e gli Slash Commands per le azioni ripetibili. Questo pacchetto copre una funzione lavorativa specifica — un plugin per il finance, per il legal, per l'audit interno. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

Dal punto di vista del pattern Coordinator-Worker, ogni Plugin è di fatto la specifica di un worker specializzato: definisce le sue capacità, gli strumenti a cui ha accesso e le azioni predefinite. La composizione di più Plugin è il modo in cui si costruisce un coordinatore capace di delegare a specialisti diversi.

### Configurazione di un Subagent tramite frontmatter YAML

Un subagent in Claude Code viene definito come file Markdown nella directory `.claude/agents/` con frontmatter YAML che controlla le sue caratteristiche operative. I campi principali hanno ciascuno un impatto architetturale preciso. *(da Introduction to Agent Skills — Intro to Agent Skills)*

Il campo `model` permette di assegnare modelli diversi a task diversi all'interno dello stesso sistema: un subagent per ricerche veloci può girare su Haiku, uno per analisi architetturale critica su Opus. Il campo `skills` elenca le Skills da iniettare nel subagent all'avvio — l'unico caso in cui il contenuto delle Skills viene precaricato integralmente invece di seguire la disclosure progressiva. Il campo `effort` controlla il livello di ragionamento del modello, permettendo di forzare un thinking più profondo su problemi ostici. *(da Introduction to Agent Skills — Intro to Agent Skills)*

Il campo `disallowedTools` è il complemento di `tools`: invece di specificare cosa il subagent può fare, specifica cosa non può fare — utile per escludere operazioni rischiose come `Write` o `Bash` su un subagent di sola analisi. Il campo `memory` controlla lo scope della memoria persistente: `project` è la scelta tipica per mantenere allineamento al progetto corrente, `none` garantisce isolamento completo. Il campo `background` a `true` permette al subagent di girare in background senza bloccare l'orchestratore. Il campo `isolation: worktree` crea una copia isolata del repository Git — se il task fallisce, la directory viene distrutta automaticamente senza lasciare file untracked. *(da Introduction to SubAgents — Intro to Subagents)*

### Gerarchia degli scope di configurazione

La posizione fisica del file di configurazione nel filesystem determina visibilità e priorità del subagent. I file in `.claude/agents/` sono specifici per il repository e vengono archiviati nel version control — ideali per la collaborazione in team. I file in `~/.claude/agents/` sono globali per l'utente e disponibili in ogni progetto locale. Le definizioni passate tramite `--agents` alla CLI hanno la priorità massima ma non persistono su disco. In caso di conflitto di nomi, la priorità è: CLI > scope personale > scope di progetto > Plugin. *(da Introduction to SubAgents — Intro to Subagents)*

### Agent Teams: Lead in Plan Mode e teammates paralleli

In scenari di ingegneria su larga scala, Claude Code può orchestrare interi Agent Teams. L'agente Lead riceve il comando macro dell'utente, entra in Plan Mode per scomporre il lavoro in task atomici e genera diversi teammates per eseguire il lavoro in parallelo. Ogni teammate è un subagent indipendente con il proprio contesto isolato. I teammates leggono il [CLAUDE.md](http://CLAUDE.md) del progetto per rimanere allineati agli standard del codebase, ma agiscono come lavoratori autonomi che riportano al Lead. *(da Introduction to Agent Skills — Intro to Agent Skills)*

### Il divieto di subagenti ricorsivi

Anthropic impedisce esplicitamente di includere lo strumento `Agent` nell'array `tools` di un subagent. I subagenti non possono generare altri subagenti in modo ricorsivo: questa limitazione è intenzionale per prevenire loop infiniti, costi fuori controllo e comportamenti impossibili da monitorare. L'orchestrazione è responsabilità esclusiva del thread principale. *(da Introduction to SubAgents — Intro to Subagents)*

## Esempi concreti

Un workflow di code review automatizzato illustra il pattern in modo concreto. Il coordinatore riceve la pull request, identifica i moduli da analizzare e delega tre task in parallelo a worker specializzati: il worker `security-analyzer` esamina le vulnerabilità, il worker `test-coverage-checker` verifica la copertura dei test, il worker `documentation-reviewer` controlla la coerenza della documentazione. Ogni worker opera su un sottoinsieme del codebase con contesto ridotto e focalizzato, producendo un JSON strutturato con un campo `status` che il coordinatore verifica prima di aggregare i risultati nel report finale. *(da Claude 101 — Claude 101)*

## Errori comuni e cosa evitare

Il fallimento silenzioso è l'anti-pattern critico: un worker che fallisce senza segnalarlo lascia il sistema in uno stato inconsistente. Ogni worker deve sempre restituire un campo `error` o `status` nell'output JSON, e il coordinatore deve sempre controllarlo prima di procedere. Un secondo errore è non prevedere un timeout per i worker: un worker bloccato può stoppare l'intero workflow se non esiste un timeout esplicito con terminazione forzata. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic è la realizzazione pratica di **Agentic loop e autonomia** (il loop distribuito su più agenti), collegato a **Modelli Claude: famiglie e differenze** (la scelta del modello per ciascun worker), a **Memory e stato negli agenti** (come il coordinatore mantiene lo stato del progetto) e a **Anatomia di una Skill: [SKILL.md](http://SKILL.md) e frontmatter** (le Skills come sistema di competenze dei subagenti).