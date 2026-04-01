# Model Context Protocol: architettura

Aggiornato: April 1, 2026 9:29 AM
Categoria: Agents & MCP
Corsi: AI Fluency, Building with the Claude API, Claude 101, Intro to Claude Cowork, Intro to MCP, MCP Advanced Topics
Stato: Da Approfondire

> 💬 MCP è il protocollo aperto che risolve il problema dell'integrazione N×M: invece di connettori custom per ogni coppia modello-strumento, un'unica interfaccia standardizzata connette qualsiasi client AI a qualsiasi sorgente di dati o servizio.
> 

## Cos'è e perché importa

Prima di MCP, integrare un modello AI con strumenti esterni significava scrivere codice di integrazione specifico per ogni combinazione. Con N modelli e M strumenti, il problema di manutenzione cresceva come N×M. MCP risolve questo problema introducendo uno strato di astrazione standard: ogni strumento implementa il protocollo una volta, e qualsiasi client che supporta MCP può usarlo immediatamente. È lo stesso principio del connettore USB applicato all'ecosistema AI — e non è una metafora casuale: MCP è stato progettato ispirandosi esplicitamente al Language Server Protocol (LSP), lo standard che ha rivoluzionato gli IDE permettendo a qualsiasi editor di comunicare con qualsiasi language server tramite un'interfaccia unificata. *(da Claude 101 — Claude 101)*

## Spiegazione

### La triade Host, Client, Server

Il protocollo si articola in tre attori con ruoli distinti. L'Host è l'applicazione finale in cui vive il modello AI: Claude Desktop, un IDE, un'applicazione custom. Il Client è il componente interno all'host che parla il protocollo MCP, gestisce la connessione con i server e funge da intermediario tra il modello e i servizi esterni. Il Server è un processo leggero che espone capacità specifiche — un database, un'API, un filesystem — attraverso le tre primitive fondamentali del protocollo. *(da Claude 101 — Claude 101)*

Il modello non comunica mai direttamente con i server MCP: passa sempre attraverso il client, che gestisce autenticazione, routing e trasformazione dei messaggi. Questo crea un confine di sicurezza chiaro e permette all'host di controllare a quali server il modello può accedere.

### I meccanismi di trasporto

MCP supporta tre meccanismi di trasporto con caratteristiche distinte. Lo stdio è il trasporto standard per server locali: il client lancia il server come processo figlio e comunica tramite stdin/stdout. È il meccanismo più semplice e sicuro per server che girano sulla stessa macchina, con latenza di comunicazione trascurabile. L'SSE (Server-Sent Events) è il trasporto per server remoti via HTTP con connessioni long-lived che mantengono lo stato — ideale per servizi condivisi o cloud. HTTP/WebSockets è la terza opzione: WebSockets offre comunicazione bidirezionale full-duplex, utile per server che devono inviare notifiche proattive al client, mentre HTTP puro è adatto per server stateless che rispondono a query singole. *(da Claude 101 — Claude 101; da Introduction to Claude Cowork — Intro to Claude Cowork)*

Il Transport è una scelta architetturale con implicazioni su sicurezza, scalabilità e latenza del loop agentico. Per agenti con alta frequenza di tool use, la differenza di latenza tra un server stdio locale e un server SSE remoto può essere significativa.

### JSON-RPC 2.0 come protocollo di comunicazione interno

Le chiamate tra client e server avvengono tramite JSON-RPC 2.0. Ogni richiesta è un oggetto JSON con un metodo (es. `tools/call`) e i parametri necessari; ogni risposta è un oggetto JSON con il risultato o un oggetto errore strutturato. Questa scelta garantisce interoperabilità con qualsiasi linguaggio o framework che supporti JSON, e rende il protocollo ispezionabile e debuggabile con strumenti standard. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

### Handshake e discovery

Ogni connessione MCP inizia con un handshake che verifica la compatibilità delle versioni del protocollo, seguito da una fase di discovery in cui il client interroga il server per ottenere la lista delle capacità disponibili. Le chiamate `tools/list`, `resources/list` e `prompts/list` sono i meccanismi standard. Il risultato è che il modello vede le capacità del server come se fossero sue proprie. *(da Claude 101 — Claude 101)*

### Il protocollo stateful e la negoziazione dinamica delle capacità

Un aspetto critico spesso sottovalutato è la natura stateful di MCP: a differenza di una semplice REST API dove ogni richiesta è indipendente, una sessione MCP ha un ciclo di vita che inizia con un handshake e termina con una chiusura esplicita. Il client mantiene connessioni 1:1 con ogni server — non connessioni condivise o pooled — quindi ogni istanza del client ha il proprio stato di sessione con ciascun server. *(da Introduction to Model Context Protocol — Intro to MCP)*

La negoziazione delle capacità può essere dinamica durante la sessione. Un server può dichiarare il flag `listChanged: true` per segnalare al client che notificherà cambiamenti all'elenco delle capacità a runtime — aggiungendo o rimuovendo tool dinamicamente in risposta a eventi esterni senza richiedere la riconnessione del client.

### MCP Tasks: operazioni asincrone a lunga esecuzione

Il corso MCP Advanced Topics introduce una funzionalità sperimentale che estende significativamente il modello operativo del protocollo. Le operazioni standard seguono un modello request-response che deve completarsi entro i limiti temporali di una singola connessione. Per operazioni che richiedono minuti od ore — analisi di repository interi, generazione di report massivi — questo modello è insufficiente. *(da Model Context Protocol: Advanced Topics — MCP Advanced Topics)*

MCP Tasks introduce un ciclo di vita asincrono a stati: un task può essere in stato `working`, `input_required` (il server ha bisogno di ulteriori informazioni), `completed` o `failed`. Il modello può continuare altre conversazioni mentre un task è in esecuzione in background, ricevendo notifica quando lo stato cambia.

### Configurazione in Claude Desktop

Per usare server MCP con Claude Desktop, è necessario registrare i server nel file `claude_desktop_config.json` (`~/Library/Application Support/Claude/` su macOS). Ogni entry specifica il comando di avvio del server e i suoi argomenti:

```json
{
  "mcpServers": {
    "sqlite": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sqlite", "--db", "/path/to/database.db"]
    },
    "google-drive": {
      "command": "python",
      "args": ["-m", "mcp_server_gdrive"],
      "env": { "GOOGLE_DRIVE_CREDENTIALS": "..." }
    }
  }
}
```

*(da Claude 101 — Claude 101)*

## Esempi concreti

Un server MCP per SQLite espone automaticamente la struttura del database come resource e permette di eseguire query come tool. Una volta configurato in Claude Desktop, il modello può rispondere a domande come "Quanti utenti attivi abbiamo questa settimana?" eseguendo autonomamente la query SQL corretta, senza che l'utente debba sapere nulla della struttura del database. Il modello sceglie il tool corretto, formula la query, ottiene il risultato e lo integra nella risposta — tutto in modo trasparente. *(da Claude 101 — Claude 101)*

## Errori comuni e cosa evitare

Un errore comune è esporre tramite MCP tool con permessi eccessivamente ampi — ad esempio un tool che può scrivere su qualsiasi tabella del database invece di essere limitato alle tabelle rilevanti per il caso d'uso. Il principio del minimo privilegio si applica ai server MCP esattamente come a qualsiasi altro sistema: ogni tool deve avere solo i permessi strettamente necessari per il suo scopo. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic è il fondamento architetturale dell'area Agents & MCP: connette **Resources, Tools e Prompts in MCP** (le tre primitive in dettaglio), **Build di server MCP in Python** (l'implementazione pratica), **Ciclo di vita connessione MCP e handshake** (la meccanica del protocollo stateful), **Sampling e notifiche MCP** (funzionalità avanzate del protocollo) e **StreamableHTTP trasporto moderno** (l'evoluzione dei meccanismi di trasporto).