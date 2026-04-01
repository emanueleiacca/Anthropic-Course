# StreamableHTTP: il trasporto moderno per MCP remoto

Aggiornato: March 31, 2026 8:15 PM
Categoria: Agents & MCP
Corsi: MCP Advanced Topics
Stato: Completo

Fonte: Model Context Protocol: Advanced Topics — MCP Advanced Topics

> 💬 StreamableHTTP è il trasporto raccomandato per tutti i deployment MCP remoti: sostituisce il modello ibrido SSE legacy con un singolo endpoint HTTP bidirezionale, ottimizzato per ambienti cloud, proxy e deployment serverless.
> 

## Cos'è e perché importa

L'MCP definisce il formato dei messaggi in modo indipendente dal trasporto, ma la scelta del meccanismo di trasporto ha conseguenze dirette e significative su scalabilità, sicurezza, latenza e compatibilità con l'infrastruttura cloud. Mentre STDIO è il trasporto corretto per server locali, i deployment remoti richiedono un trasporto HTTP. Il protocollo MCP ha attraversato un'evoluzione in questo campo: il modello originale basato su SSE ha mostrato limitazioni concrete in ambienti cloud, e StreamableHTTP è la risposta architetturale a questi problemi. *(da Model Context Protocol: Advanced Topics — MCP Advanced Topics)*

A partire dal 2025, StreamableHTTP è il trasporto raccomandato per tutte le nuove implementazioni MCP remote. Conoscere la differenza tra SSE e StreamableHTTP è necessario sia per progettare nuovi server sia per valutare la migrazione di server esistenti.

## Spiegazione

### Il modello SSE legacy e i suoi limiti

Il trasporto originale per connessioni remote MCP usava un modello ibrido: le richieste dal client al server viaggiavano tramite HTTP POST su un endpoint dedicato, mentre le risposte e gli stream dal server al client viaggiavano tramite Server-Sent Events (SSE) su un endpoint GET separato. Questo richiedeva quindi due endpoint distinti: uno per i messaggi del client e uno per lo stream del server. *(da Model Context Protocol: Advanced Topics — MCP Advanced Topics)*

Il problema principale di questo approccio è la natura delle connessioni SSE: sono connessioni persistenti unidirezionali che devono rimanere aperte per tutta la durata della sessione. Gateway HTTP, proxy aziendali e load balancer spesso non gestiscono bene connessioni di questo tipo: possono chiuderle per timeout, non supportare correttamente il buffering degli eventi, o creare problemi di scalabilità nei deployment cloud dove ogni connessione SSE occupa una risorsa sul server. I servizi serverless come Azure Functions o Cloudflare Workers, che non supportano connessioni persistenti, sono di fatto incompatibili con il modello SSE.

### StreamableHTTP: un singolo endpoint bidirezionale

StreamableHTTP risolve questi problemi consolidando tutta la comunicazione su un singolo endpoint HTTP (tipicamente `/mcp`). Le richieste del client viaggiano come HTTP POST verso questo endpoint; le risposte del server possono essere restituite come HTTP chunking nativo (per risposte immediate o brevi) oppure come SSE opzionale sullo stesso canale (per stream lunghi o notifiche). *(da Model Context Protocol: Advanced Topics — MCP Advanced Topics)*

La parola chiave è "opzionale": invece di richiedere sempre una connessione SSE persistente, StreamableHTTP usa lo streaming solo quando è necessario e si degrada graciosamente a HTTP normale per le risposte che possono essere restituite in modo sincrono. Questo rende il trasporto compatibile con proxy, gateway e load balancer standard che non hanno supporto speciale per SSE.

### Resilienza e gestione delle disconnessioni

StreamableHTTP include meccanismi di resilienza nativi attraverso l'header `Last-Event-ID`. Se la connessione si interrompe durante uno stream, il client può riconnettersi inviando l'ID dell'ultimo evento ricevuto: il server riprende lo stream dal punto di interruzione invece di ricominciare dall'inizio. Questo è particolarmente importante per operazioni lunghe dove una disconnessione di rete intermittente non deve richiedere di ripetere l'intera elaborazione. *(da Model Context Protocol: Advanced Topics — MCP Advanced Topics)*

Il modello SSE legacy gestiva le disconnessioni in modo non standardizzato: ogni implementazione doveva gestire la logica di reconnessione in modo custom. StreamableHTTP standardizza questo comportamento a livello di protocollo.

### Quando usare STDIO vs StreamableHTTP

La scelta tra i due trasporti è determinata dalla topologia del deployment. STDIO è il trasporto corretto per tutti i server che girano sulla stessa macchina dell'host: strumenti di sviluppo locale, integrazioni con IDE, server personali. È il più semplice da configurare, ha latenza minima e gestione sicura dei permessi tramite l'account utente locale. StreamableHTTP è il trasporto corretto per server remoti: API enterprise condivise tra molti utenti, server su infrastruttura cloud, integrazioni con servizi esterni che richiedono deployment dedicati.

## Esempi concreti

Avviare un server FastMCP con StreamableHTTP richiede solo di specificare il parametro `transport`:

```python
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("RemoteProductionServer")

@mcp.tool()
async def search_database(query: str, limit: int = 10) -> str:
    """Esegue una ricerca nel database aziendale."""
    results = await db.search(query, limit=limit)
    return format_results(results)

if __name__ == "__main__":
    # Tutti i client si connettono a http://server:8000/mcp
    mcp.run(transport="streamable-http", host="0.0.0.0", port=8000)
```

Per il deployment serverless, la stessa logica funziona senza modifiche al codice del server: è il runtime serverless a gestire la gestione delle connessioni. *(da Model Context Protocol: Advanced Topics — MCP Advanced Topics)*

## Errori comuni e cosa evitare

L'errore più comune è iniziare un deployment remoto con SSE perché è la modalità documentata nei tutorial più vecchi, e poi dover migrare quando si incontrano i problemi di compatibilità con proxy e gateway. Per qualsiasi nuovo server remoto, StreamableHTTP dovrebbe essere la scelta di default. *(da Model Context Protocol: Advanced Topics — MCP Advanced Topics)*

Un secondo errore è non implementare la validazione dell'header `Origin` nei server StreamableHTTP. Anche con un singolo endpoint, un server accessibile da browser è vulnerabile ad attacchi di DNS rebinding se non verifica che l'Origin delle richieste sia tra quelli autorizzati.

## Connessioni ad altri topic

Questo topic è la specializzazione tecnica del trasporto remoto rispetto a **Model Context Protocol: architettura** (che tratta il framework generale), collegato a **Scalabilità e stato nei sistemi MCP** (dove StreamableHTTP è il prerequisito per il deployment stateless), a **Ciclo di vita della connessione MCP e handshake** (l'handshake avviene via StreamableHTTP per server remoti) e a **Sicurezza avanzata in MCP** (la validazione Origin come protezione contro DNS rebinding).