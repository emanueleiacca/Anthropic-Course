# Gestione errori e retry

Aggiornato: April 1, 2026 9:15 AM
Categoria: API & Tools
Corsi: Building with the Claude API, Claude 101, Claude Code in Action, Intro to MCP
Stato: Completo

> 💬 In produzione, la gestione di errori e retry non è un dettaglio implementativo: è parte dell'architettura del sistema, e il campo stop_reason è il segnale primario per decidere come rispondere a ogni tipo di interruzione.
> 

## Cos'è e perché importa

Un'applicazione che chiama l'API di Claude in produzione affronta inevitabilmente scenari di errore: rate limit raggiunto, timeout di rete, risposte troncate per via del limite di token, tool call che richiedono esecuzione esterna. Gestire questi casi in modo robusto — con strategie di retry appropriate, comunicazione chiara all'utente e continuazione corretta del flusso — è la differenza tra un prototipo e un sistema enterprise-grade. *(da Claude 101 — Claude 101)*

## Spiegazione

### Il campo stop_reason come guida alla gestione

Il primo livello di gestione degli errori non riguarda le eccezioni di rete, ma il campo `stop_reason` nella risposta. Questo campo segnala come si è conclusa la generazione e determina l'azione corretta da intraprendere. Quando vale `end_turn`, la generazione si è conclusa normalmente e non è necessaria alcuna azione speciale. Quando vale `max_tokens`, la generazione è stata interrotta perché il limite di token configurato è stato raggiunto — il testo è incompleto, e se il contesto lo permette si può costruire una richiesta di continuazione aggiungendo la risposta parziale alla history e chiedendo al modello di proseguire. Quando vale `tool_use`, il modello ha richiesto l'esecuzione di una funzione esterna: non si tratta di un errore ma di un segnale che il flusso agentico deve proseguire con l'esecuzione del tool e l'invio del risultato nella richiesta successiva. *(da Claude 101 — Claude 101)*

### Rate limit e backoff esponenziale

L'API restituisce errori HTTP 429 quando viene superato il rate limit. La strategia corretta è il backoff esponenziale con jitter: si attende un tempo crescente tra i tentativi (1s, 2s, 4s, 8s...) con un piccolo componente randomico per evitare che più istanze dello stesso servizio si sincronizzino nel retry e creino picchi ulteriori. L'SDK Python di Anthropic gestisce questa logica automaticamente per default, ma è importante conoscerla per implementazioni custom. *(da Claude 101 — Claude 101)*

### Failover verso modello di backup e strumenti di gateway

Una dimensione importante della gestione degli errori in produzione è la strategia di failover per gli errori 500 e 529 (Internal Server Error e Overloaded). Invece di limitarsi al retry sul modello primario, un sistema robusto implementa un fallback verso un modello alternativo dello stesso tier — ad esempio passare da Opus a Sonnet quando Opus è sovraccarico. Questo richiede che il sistema sia progettato per essere agnostico rispetto al modello specifico, con prompt compatibili con entrambe le opzioni. *(da Building with the Claude API — Building with the Claude API)*

Per i sistemi ad alto volume con più tenant, strumenti di AI Gateway come Portkey permettono la gestione centralizzata dei rate limit su più account. Distribuire le richieste tra account diversi tramite un gateway evita di concentrare tutto il carico su un unico account, riducendo la frequenza degli errori 429 senza dover implementare logiche di load balancing custom.

### Timeout e errori di rete

Per le chiamate sincrone con risposte lunghe, configurare un timeout appropriato è essenziale. Per le chiamate in streaming, la gestione della disconnessione richiede di tracciare il testo già ricevuto e decidere se la risposta parziale è sufficiente o se è necessario ripetere l'intera richiesta.

### Debugging di server MCP: log e riavvio obbligatorio

Nel contesto specifico del debugging di server MCP integrati in Claude Desktop, i log dell'applicazione host sono il primo punto da consultare quando un server non si connette. Su macOS si trovano in `~/Library/Logs/Claude`, su Windows in `%APPDATA%\Claude\logs`. Contengono i messaggi di errore generati durante l'avvio e la comunicazione con i server MCP. *(da Introduction to Model Context Protocol — Intro to MCP)*

Un dettaglio operativo critico: le modifiche al codice di un server MCP STDIO richiedono un riavvio completo di Claude Desktop per essere caricate. L'host avvia il processo del server all'apertura della sessione e lo mantiene attivo fino alla chiusura — modificare il codice senza riavviare l'host produce il vecchio comportamento, non il nuovo.

### Installazione e diagnostica di Claude Code

Per i problemi di installazione di Claude Code, il comando `claude doctor` esegue una diagnosi delle dipendenze (git, ripgrep) e della connessione di rete. L'installazione tramite `sudo npm install -g` è sconsigliata perché può generare errori di permessi durante l'esecuzione dei tool secondari; il metodo raccomandato è lo script shell ufficiale. Homebrew non si aggiorna automaticamente e richiede `brew upgrade` periodico. *(da Claude Code in Action — Claude Code in Action)*

## Esempi concreti

Un wrapper robusto per la chiamata API gestisce tutti e tre i valori di `stop_reason` oltre alle eccezioni di rete:

```python
def safe_call(client, messages, system, max_retries=3):
    for attempt in range(max_retries):
        try:
            response = client.messages.create(
                model="claude-sonnet-4-6",
                max_tokens=2048,
                system=system,
                messages=messages
            )
            if response.stop_reason == "max_tokens":
                # Gestione continuazione: aggiungi risposta parziale e richiedi proseguimento
                pass
            return response
        except anthropic.RateLimitError:
            time.sleep(2 ** attempt + random.random())
        except anthropic.InternalServerError:
            # Failover verso modello alternativo al terzo tentativo
            if attempt == 2:
                return fallback_call(client, messages, system)
            time.sleep(1)
    raise Exception("Max retries exceeded")
```

*(da Claude 101 — Claude 101)*

## Errori comuni e cosa evitare

Il fallimento silenzioso è l'anti-pattern più pericoloso: un sistema che non gestisce `stop_reason == tool_use` in un contesto agentico interrompe il loop senza segnalarlo, restituendo una risposta incompleta che sembra valida ma non lo è. Altrettanto pericolosa è la gestione dei retry senza backoff: chiamare l'API ripetutamente ad alta frequenza dopo un errore 429 peggiora la situazione invece di risolverla — ogni chiamata aggiuntiva prima che la finestra di rate limit si resetti porta a un ban temporaneo sempre più lungo. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic è collegato a **Messages API: struttura e parametri** (il campo stop_reason è parte dell'oggetto risposta), a **Streaming delle risposte** (la gestione della disconnessione mid-stream), ad **Agentic loop e autonomia** (il `stop_reason == tool_use` come meccanismo di orchestrazione) e a **Batch API** (la gestione dei fallimenti parziali nel batch).