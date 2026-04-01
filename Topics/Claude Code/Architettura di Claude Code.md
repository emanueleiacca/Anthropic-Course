# Architettura di Claude Code

Aggiornato: April 1, 2026 2:08 PM
Categoria: Claude Code
Corsi: AI Fluency, Building with the Claude API, Claude 101, Claude Code in Action, Intro to Agent Skills, Intro to Claude Cowork, Intro to MCP, Intro to Subagents, MCP Advanced Topics
Stato: Da Approfondire

> 💬 Claude Desktop non è un semplice wrapper per il chat: è un ambiente operativo diviso in tre tab con architetture e casi d'uso fondamentalmente diversi — Chat per il ragionamento, Cowork per i task lunghi in VM isolata, Code per il lavoro diretto sul filesystem.
> 

## Cos'è e perché importa

Comprendere le differenze architetturali tra le tre tab di Claude Desktop è essenziale per usarlo correttamente come strumento professionale. Usare Code quando si intende usare Cowork, o viceversa, non è solo una questione di preferenza: le due tab hanno accesso a risorse diverse, garanzie di sicurezza diverse e casi d'uso genuinamente distinti. *(da Claude 101 — Claude 101)*

## Spiegazione

### Tab Chat: ragionamento puro

La tab Chat è ottimizzata per conversazioni generali senza accesso diretto al filesystem locale dell'utente. È l'ambiente corretto per brainstorming, analisi di documenti caricati manualmente, domande di ragionamento complesso, revisione di testo. Non esegue codice, non modifica file, non ha accesso a servizi locali. È la tab più simile all'esperienza web di [Claude.ai](http://Claude.ai). *(da Claude 101 — Claude 101)*

### Tab Cowork: l'agente asincrono in VM

La tab Cowork è un agente autonomo che opera all'interno di una macchina virtuale sicura, separata e isolata dal sistema operativo dell'utente. Questo ha implicazioni architetturali precise: le azioni di Cowork avvengono in un ambiente controllato, con accesso alla rete e ai file gestito attraverso policy esplicite, non direttamente sul filesystem locale. *(da Claude 101 — Claude 101)*

Il caso d'uso distintivo è il task a lungo termine: si assegna un compito complesso e si può chiudere l'applicazione. Quando si torna, il lavoro è completato. Questo è possibile perché Cowork gira in background come processo persistente, indipendente dalla sessione attiva.

Il corso Intro to Claude Cowork chiarisce che Cowork è progettato specificamente per il profilo dell'utente non-tecnico che vuole delegare task complessi senza scrivere codice. Rispetto a Claude Code, è ottimizzato per workflow desktop e aziendali invece che per flussi di sviluppo software. Anthropic ha sviluppato Cowork osservando come i team non tecnici cercassero di usare Claude Code — nato per sviluppatori — per gestire task desktop. I modelli specifici sono Claude Sonnet 4.5 per i task operativi e Claude Opus 4.6 per quelli che richiedono ragionamento più profondo. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

### Tab Code: integrazione profonda con il filesystem

La tab Code è progettata per il lavoro di sviluppo software e opera direttamente sul filesystem locale. Questo accesso diretto permette un'integrazione profonda con il flusso di lavoro del programmatore: Claude può leggere file, proporre modifiche, eseguire comandi nel terminale locale.

La funzionalità distintiva è la Visual Diff Review: invece di riscrivere direttamente il codice, Claude propone le modifiche in formato diff che l'utente deve approvare esplicitamente. Questo mantiene l'umano nel loop per ogni modifica, riducendo il rischio di cambiamenti indesiderati. Per refactoring più estesi, la modalità Plan genera prima un piano d'azione che l'utente approva, e solo poi esegue le modifiche in sequenza. *(da Claude 101 — Claude 101)*

Il corso AI Fluency aggiunge che Claude Code è nato in febbraio 2025 come strumento CLI prima di evolvere verso l'integrazione desktop. Questa origine è rilevante per capire la filosofia del tool: progettato per sviluppatori che lavorano nel terminale e vogliono integrare l'agente nel proprio workflow esistente, non per chi vuole un'interfaccia grafica separata. *(da AI Fluency — AI Fluency)*

### Le cinque aree di agency

Il corso Claude Code in Action formalizza le capacità operative in cinque domini funzionali distinti. Le Operazioni su File comprendono lettura, scrittura, creazione, rinomina e riorganizzazione: sono il fondamento del refactoring su larga scala. La Ricerca include pattern matching e regex su intero codebase: riduce i tempi di navigazione in progetti non familiari. L'Esecuzione abbraccia comandi shell, avvio server, test suite e comandi Git: permette la validazione deterministica del lavoro. Il Web fornisce ricerca internet e recupero documentazione esterna: il punto di accesso a conoscenze aggiornate oltre la data di training. L'Intelligenza Codice include navigazione delle definizioni e analisi di errori di tipo: richiede plugin LSP per la massima precisione. *(da Claude Code in Action — Claude Code in Action)*

### Sintassi di riferimento contestuale

Il corso introduce simboli di controllo per guidare il comportamento di Claude Code con precisione. Il simbolo `@` aggiunge file o directory specifici al contesto immediato. Il simbolo `#` inserisce un'istruzione persistente nella memoria della sessione. Il simbolo `!` esegue un comando shell all'interno di una Skill per iniettare output dinamico nel contesto. Il simbolo `/` invoca comandi integrati o Skills personalizzate. *(da Claude Code in Action — Claude Code in Action)*

### Il file [CLAUDE.md](http://CLAUDE.md): istruzioni specifiche per progetto

Il corso Building with the Claude API introduce il file `CLAUDE.md` alla radice del repository: viene letto automaticamente dall'agente all'avvio e fornisce istruzioni specifiche del progetto che integrano il comportamento di default. Il contenuto tipico include convenzioni di naming, comandi di test, linee guida di stile, pattern architetturali preferiti e dipendenze da non toccare. In un team, questo file è versionato con il repository e garantisce che l'agente si comporti in modo coerente per tutti i membri indipendentemente dalla configurazione locale. *(da Building with the Claude API — Building with the Claude API)*

### [CLAUDE.md](http://CLAUDE.md), Skills e Auto Memory: quando usare cosa

Il corso Intro to Agent Skills fornisce la mappa definitiva per orientarsi tra i meccanismi di istruzioni persistenti in Claude Code. Il file [CLAUDE.md](http://CLAUDE.md) è destinato a regole globali sempre attive: standard di linting, formati di commit, comandi di build. Viene caricato all'avvio e occupa spazio permanente nella finestra di contesto — va usato con parsimonia. Le Agent Skills sono pacchetti di conoscenza on-demand: vengono caricate solo quando il task corrente corrisponde alla loro descrizione, con costo zero nella maggior parte delle conversazioni. L'Auto Memory cattura pattern comportamentali sottili osservando le correzioni dell'utente durante le sessioni, senza richiedere configurazione manuale. *(da Introduction to Agent Skills — Intro to Agent Skills)*

La distinzione operativa è semplice: [CLAUDE.md](http://CLAUDE.md) per ciò che ogni sviluppatore del team deve sempre rispettare; Skills per workflow specialistici specifici; Auto Memory per le preferenze personali dell'utente.

### Sub-agenti con accesso MCP limitato per isolamento dei compiti

Il corso MCP Advanced Topics descrive un pattern architetturale importante: i sub-agenti in Claude Code sono istanze con contesti isolati che ricevono accesso a un sottoinsieme limitato di strumenti MCP. Un sub-agente di ricerca può ricevere solo tool di lettura file (nessun tool di scrittura, nessun tool di esecuzione), garantendo che non possa modificare il codice sorgente durante l'analisi. Un sub-agente di scrittura usa solo tool di modifica file; uno di verifica usa solo tool di esecuzione test. L'orchestratore coordina i tre senza che nessuno abbia accesso al di fuori del proprio dominio. *(da Model Context Protocol: Advanced Topics — MCP Advanced Topics)*

### Pattern di deployment enterprise: gateway MCP

Il corso Intro to MCP introduce un pattern architetturale avanzato per deployment aziendali: invece di far connettere ogni client a decine di micro-server MCP individuali, si utilizza un gateway MCP che aggrega le capacità di più server specialistici. Il gateway gestisce l'autenticazione centralizzata, applica policy di sicurezza e rate-limiting, e fa da intermediario tra il client e i server downstream. Risolve due problemi: la riduzione dell'overhead di token (implementa progressive disclosure selettiva) e la governance centralizzata (gestisce autenticazione e policy su un unico punto invece che su ogni server individualmente). *(da Introduction to Model Context Protocol — Intro to MCP)*

### Changelog SDK marzo 2026: aggiornamenti critici

L'header `X-Claude-Code-Session-Id` permette ai proxy aziendali di correlare le richieste per sessione senza decriptare il corpo del messaggio. La variabile `CLAUDE_CODE_NO_FLICKER=1` risolve problemi di rendering nei terminali virtualizzati durante l'output massivo dei subagenti. Il fix del Context Leak risolve un bug critico dove i file [CLAUDE.md](http://CLAUDE.md) annidati venivano re-iniettati decine di volte in sessioni lunghe, causando consumo esponenziale di token. La ridenominazione del tool da `Task` a `Agent` dalla versione 2.1.63 richiede aggiornamento del codice SDK scritto prima di questa versione. *(da Introduction to SubAgents — Intro to Subagents)*

## Esempi concreti

Un workflow tipico combinato: si usa la tab Chat per discutere l'architettura di un nuovo feature, si passa alla tab Code per l'implementazione con diff review, e si usa Cowork per la generazione automatizzata della documentazione tecnica e dei test di integrazione — tutto in parallelo, senza bloccare la sessione di sviluppo attiva. *(da Claude 101 — Claude 101)*

## Errori comuni e cosa evitare

Un errore comune è usare la tab Code per task che richiedono tempo lungo, aspettandosi che il processo continui in background: Code è una sessione interattiva, non un processo persistente. Per task che richiedono ore, Cowork è la scelta corretta. Un secondo errore è disabilitare la diff review nella tab Code pensando di accelerare il workflow: la revisione esplicita delle modifiche è una salvaguardia importante, soprattutto in codebase condivisi o in produzione. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic è il punto di ingresso all'area Claude Code: connette **Context management nel codice** (come gestire il contesto nella tab Code), **Multi-tool use e flussi complessi** (l'orchestrazione di task in Cowork), **Agent Skills in Claude Code** (le Skills come capacità modulari della tab Code) e **Integrazione MCP + GitHub** (l'accesso ai repository tramite MCP nella tab Code).