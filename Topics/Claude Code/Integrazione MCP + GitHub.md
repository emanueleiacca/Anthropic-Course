# Integrazione MCP + GitHub

Aggiornato: April 1, 2026 2:10 PM
Categoria: Claude Code
Corsi: Claude 101, Claude Code in Action
Stato: Da Approfondire

> 💬 Connettere Claude Code a GitHub via MCP abilita workflow completi end-to-end: lettura issue, checkout branch, commit e PR senza uscire dall'agente. Il comando `claude mcp add` è il punto di ingresso per qualsiasi integrazione MCP in Claude Code.
> 

## Cos'è e perché importa

Il valore di Claude Code come agente di sviluppo dipende dalla qualità degli strumenti a cui ha accesso. Senza integrazione con i sistemi di controllo versione e i servizi del ciclo di vita dello sviluppo software, l'agente è limitato al filesystem locale: può modificare file ma non aprire PR, può correggere bug ma non creare issue, può analizzare il codice ma non accedere ai log di produzione. L'integrazione MCP + GitHub — e più in generale l'integrazione con i servizi dello stack di sviluppo — trasforma Claude Code da editor intelligente a collaboratore tecnico che opera sull'intero ciclo di vita del software. *(da Claude Code in Action — Claude Code in Action)*

## Spiegazione

### Il comando claude mcp add

L'aggiunta di server MCP a Claude Code avviene tramite il comando `claude mcp add`. La sintassi base specifica il trasporto, il nome del server e l'endpoint:

```bash
claude mcp add --transport http github https://mcp.github.com/
```

Il flag `--transport http` è necessario per server remoti. Per server locali stdio, il flag non è necessario e il comando accetta il percorso all'eseguibile del server. *(da Claude Code in Action — Claude Code in Action)*

Il server MCP GitHub espone le operazioni fondamentali come tool: lettura e creazione di issue, checkout e gestione branch, staging e commit, apertura e aggiornamento di pull request. Claude può invocare questi tool nel contesto del normale flusso di lavoro, senza che l'utente debba uscire dall'agente per aprire il browser o il terminale Git.

### Workflow avanzato: @claude nei commenti GitHub

Un workflow avanzato documentato nel corso prevede l'invocazione di `@claude` direttamente nei commenti di una PR su GitHub. L'agente legge il commento, analizza il diff della PR, apporta le modifiche necessarie nel repository e aggiorna la PR in modo asincrono — senza che lo sviluppatore debba aprire l'editor localmente. Questo pattern è particolarmente utile per feedback di code review che richiedono modifiche meccaniche (correzioni di stile, aggiornamento di test, refactoring semplice). *(da Claude Code in Action — Claude Code in Action)*

### Integrazioni ad alto valore per il workflow quotidiano

Oltre a GitHub, tre integrazioni MCP sono documentate come particolarmente preziose negli ambienti di sviluppo professionali. Playwright consente a Claude di navigare il web, eseguire il rendering di pagine JavaScript e acquisire screenshot: essenziale per validare cambiamenti di UI/UX senza dover aprire un browser manualmente. PostgreSQL/BigQuery permette all'agente di interrogare schemi e dati direttamente, utile per assistere nella migrazione di database o nell'analisi delle performance delle query. Sentry consente a Claude di monitorare log di errori in produzione e correlarli al codice sorgente locale per una risoluzione rapida dei bug segnalati dagli utenti. *(da Claude Code in Action — Claude Code in Action)*

## Esempi concreti

Un workflow tipico con l'integrazione GitHub: Claude riceve la richiesta "Correggi il bug segnalato nell'issue #147". L'agente legge l'issue tramite il tool MCP GitHub, analizza la descrizione e i commenti, identifica il file responsabile leggendo il codebase locale, applica la correzione, esegue i test unitari, crea un commit con un messaggio descrittivo basato sull'issue, e apre una PR con la descrizione del fix — tutto senza che l'utente esca dall'interfaccia dell'agente. *(da Claude Code in Action — Claude Code in Action)*

## Errori comuni e cosa evitare

Un errore frequente è non configurare correttamente le credenziali di autenticazione per i server MCP remoti. Il server GitHub richiede un token di accesso personale o una configurazione OAuth: senza autenticazione corretta, le chiamate ai tool falliscono con errori 401 che possono sembrare problemi di connessione invece che di credenziali. Le credenziali devono essere gestite tramite variabili d'ambiente, non hardcodate nella configurazione.

Un secondo errore è attivare contemporaneamente molti server MCP pesanti (GitHub con ~40 tool, Linear con ~27) senza considerare l'overhead di token delle definizioni: insieme consumano quasi il 10% di una finestra da 200k token prima che l'utente abbia inviato il primo messaggio. Per sessioni con contesti ampi, è preferibile attivare solo i server strettamente necessari per il task corrente.

## Connessioni ad altri topic

Questo topic è la specializzazione Claude Code di **Model Context Protocol: architettura** (il protocollo che abilita le integrazioni), collegato a **Build di server MCP in Python** (per integrazioni custom con servizi interni), a **Context Window e Token** (l'overhead di token dei server MCP attivi) e a **Agentic loop e autonomia** (i tool MCP come azioni disponibili nel loop agentico di Claude Code).