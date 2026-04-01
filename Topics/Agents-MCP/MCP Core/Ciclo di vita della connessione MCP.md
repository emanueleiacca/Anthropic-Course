# Ciclo di vita della connessione MCP e handshake

Aggiornato: April 1, 2026 9:33 AM
Categoria: Agents & MCP
Corsi: Intro to MCP, MCP Advanced Topics
Stato: Completo

> 💬 MCP è un protocollo stateful: ogni sessione ha un ciclo di vita preciso che inizia con un handshake a tre fasi per negoziare le capacità e termina con una chiusura esplicita. Capire questa sequenza è essenziale per implementare client e server robusti.
> 

## Cos'è e perché importa

A differenza di una REST API dove ogni richiesta è completamente indipendente, MCP è un protocollo stateful: client e server devono stabilire una sessione, concordare le versioni del protocollo e negoziare quali capacità ciascuno supporta prima di poter scambiare messaggi operativi. Questo approccio garantisce che non ci siano mai incompatibilità silenziose: se client e server non concordano sulla versione o sulle capacità richieste, la connessione fallisce in modo esplicito durante l'inizializzazione invece di produrre comportamenti inattesi durante l'operazione. *(da Introduction to Model Context Protocol — Intro to MCP)*

## Spiegazione

### La sequenza di handshake a tre fasi

Prima che qualsiasi scambio operativo possa avvenire, client e server devono completare una sequenza precisa di tre messaggi. *(da Introduction to Model Context Protocol — Intro to MCP)*

Il primo messaggio è l'Initialize Request, inviato dal client al server: contiene la versione del protocollo desiderata, le metainformazioni del client e l'elenco delle capacità supportate (sampling, notifiche di progresso, estensioni del protocollo).

Il secondo messaggio è l'Initialize Response del server: conferma la versione del protocollo che verrà usata e dichiara le proprie capacità (tools, resources, prompts, logging e i rispettivi flag).

Il terzo messaggio è l'Initialized Notification del client: un messaggio unidirezionale che segnala al server di aver processato correttamente la response e di essere pronto agli scambi operativi. Solo dopo questa notifica il server può ricevere richieste operative.

### Negoziazione dinamica delle capacità e degradazione graziosa

Non tutti i server devono supportare tutte le primitive: un server può dichiarare solo resources senza tools, o solo tools senza prompts. La negoziazione durante l'handshake garantisce che il client sappia esattamente cosa può fare con quel server. *(da Introduction to Model Context Protocol — Intro to MCP)*

Il corso MCP Advanced Topics approfondisce una conseguenza pratica: la degradazione graziosa. Se il client non dichiara il supporto per le notifiche di progresso, il server non le emette. Se il client non supporta il sampling, il server non può richiederlo. Questo design garantisce interoperabilità tra implementazioni con capacità diverse: un server avanzato funziona correttamente anche con client più semplici, operando con il sottoinsieme di funzionalità comuni negoziate all'avvio. *(da Model Context Protocol: Advanced Topics — MCP Advanced Topics)*

La negoziazione può essere dinamica durante la sessione. Il flag `listChanged: true` nelle capacità dichiarate segnala al client che il server notificherà cambiamenti all'elenco delle proprie capacità a runtime senza richiedere la riconnessione.

### I quattro tipi di messaggio JSON-RPC 2.0

Ogni comunicazione MCP usa il formato JSON-RPC 2.0, che definisce quattro tipi di messaggio con semantiche precise. Le Request sono chiamate a metodi specifici con parametri opzionali e richiedono sempre una risposta. I Result sono risposte di successo a una request precedente. Gli Error sono risposte di fallimento con codice e messaggio. Le Notification sono messaggi unidirezionali per aggiornamenti o eventi che non richiedono risposta. *(da Introduction to Model Context Protocol — Intro to MCP)*

Questa distinzione è importante per la gestione corretta del timeout e del retry: solo le Request attendono una risposta. Un client che aspetta una risposta a una Notification è destinato a bloccarsi indefinitamente.

### Mcp-Session-Id e gestione dell'identità della sessione

Per il trasporto HTTP, il server assegna un identificativo univoco alla sessione tramite l'header `Mcp-Session-Id`, che il client deve includere in tutte le richieste successive. La gestione di questo ID diventa critica in architetture con load balancer: se richieste successive con lo stesso `Mcp-Session-Id` arrivano a nodi diversi, il nodo che non ha effettuato l'handshake non conosce lo stato della sessione. Questo è il problema centrale della scalabilità stateful trattato nel topic dedicato. *(da Model Context Protocol: Advanced Topics — MCP Advanced Topics)*

## Esempi concreti

Una sequenza di handshake in pseudocodice che illustra il flusso completo delle tre fasi:

```json
// 1. Client invia Initialize Request
{"jsonrpc": "2.0", "id": 1, "method": "initialize",
 "params": {
   "protocolVersion": "2024-11-05",
   "clientInfo": {"name": "Claude Desktop", "version": "1.0"},
   "capabilities": {"sampling": {}, "roots": {"listChanged": true}}
 }}

// 2. Server risponde con Initialize Response
{"jsonrpc": "2.0", "id": 1, "result": {
   "protocolVersion": "2024-11-05",
   "serverInfo": {"name": "my-mcp-server", "version": "0.1"},
   "capabilities": {
     "tools": {"listChanged": true},
     "resources": {},
     "logging": {}
   }
}}

// 3. Client invia Initialized Notification (nessuna risposta attesa)
{"jsonrpc": "2.0", "method": "notifications/initialized"}
```

*(da Introduction to Model Context Protocol — Intro to MCP)*

## Errori comuni e cosa evitare

L'errore più comune è tentare di inviare richieste operative prima che l'handshake sia completato: alcuni client ricevono la Initialize Response e iniziano immediatamente senza inviare la Initialized Notification, causando comportamenti imprevedibili perché il server potrebbe non aver completato la propria fase di setup. *(da Introduction to Model Context Protocol — Intro to MCP)*

Un secondo errore è non gestire il caso in cui il server supporta una versione del protocollo diversa da quella richiesta. La connessione deve fallire in modo esplicito e informativo, non procedere silenziosamente con comportamenti parziali.

## Connessioni ad altri topic

Questo topic è la base operativa di **Model Context Protocol: architettura** (il framework generale), prerequisito per **Sampling e notifiche MCP** (il sampling è una capacità negoziata durante l'handshake), collegato a **MCP Inspector e debugging** (l'Inspector permette di osservare il handshake in isolamento) e a **Scalabilità e stato nei sistemi MCP** (il problema del Mcp-Session-Id in architetture distribuite).