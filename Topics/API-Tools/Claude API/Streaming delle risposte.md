# Streaming delle risposte

Aggiornato: April 1, 2026 9:13 AM
Categoria: API & Tools
Corsi: Building with the Claude API, Claude 101
Stato: Completo

> 💬 Lo streaming permette di mostrare i token man mano che vengono generati, trasformando l'esperienza utente da una lunga attesa silenziosa a una risposta che "appare" in tempo reale — ma gestirlo correttamente richiede attenzione al campo stop_reason e alla sequenza completa degli eventi SSE.
> 

## Cos'è e perché importa

In un'applicazione conversazionale, la latenza percepita dall'utente è determinata principalmente dal "time to first token" (TTFT): il tempo che intercorre tra l'invio della richiesta e la ricezione del primo carattere visibile della risposta. Senza streaming, l'utente vede uno schermo vuoto per tutta la durata della generazione e poi riceve la risposta completa in un colpo solo. Con lo streaming, vede i token arrivare progressivamente, rendendo l'interazione molto più naturale anche quando la risposta è lunga. *(da Claude 101 — Claude 101)*

## Spiegazione

### Il meccanismo SSE (Server-Sent Events)

Lo streaming con l'API Anthropic avviene tramite Server-Sent Events: il server mantiene aperta la connessione HTTP e invia eventi progressivamente invece di attendere il completamento della risposta. Ogni evento contiene un frammento del testo generato (`delta`) e l'SDK Python gestisce trasparentemente il protocollo SSE, esponendo allo sviluppatore un'interfaccia iterabile:

```python
with client.messages.stream(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Spiega l'architettura MCP"}]
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)
```

### La sequenza completa degli eventi SSE

Il protocollo SSE di streaming è più ricco di quanto la semplice iterazione sul `text_stream` lasci trasparire. La sequenza completa degli eventi è la seguente: `message_start` porta i metadati iniziali della risposta — ID del messaggio, modello usato, utilizzo parziale dei token. `content_block_start` segnala l'inizio di un nuovo blocco di contenuto. `content_block_delta` porta i frammenti incrementali del testo generato. `content_block_stop` segnala la fine del blocco corrente. `message_delta` porta le statistiche finali sull'uso totale dei token e il `stop_reason`. `message_stop` chiude la connessione. *(da Building with the Claude API — Building with the Claude API)*

Comprendere questa sequenza è importante per due ragioni pratiche. La prima riguarda il tool use in streaming: quando Claude decide di invocare un tool, il `content_block_start` segnala un blocco di tipo `tool_use` invece di `text`, e i `content_block_delta` successivi portano gli argomenti JSON del tool invece di testo narrativo. Un sistema di streaming che non discrimina il tipo di blocco tratta le chiamate tool come testo da visualizzare, producendo output incoerenti. La seconda ragione riguarda il monitoraggio real-time dei token: i metadati distribuiti negli eventi permettono di tracciare l'utilizzo durante la generazione invece che solo al termine, utile per sistemi con budget di token per sessione. *(da Building with the Claude API — Building with the Claude API)*

### Il campo stop_reason e la gestione robusta

Il campo `stop_reason` nella risposta finale indica come si è conclusa la generazione e determina l'azione corretta da intraprendere. Quando vale `end_turn`, il modello ha concluso naturalmente e la risposta è completa: nessuna azione aggiuntiva necessaria. Quando vale `max_tokens`, la generazione è stata troncata dal limite impostato — il testo è incompleto e si può opzionalmente richiedere una continuazione aggiungendo la risposta parziale alla history e chiedendo al modello di proseguire da dove si è fermato. Quando vale `tool_use`, il modello non ha prodotto una risposta testuale finale ma sta richiedendo l'esecuzione di una funzione esterna: il loop agentico deve continuare eseguendo il tool e inviando il risultato. *(da Claude 101 — Claude 101)*

In un sistema di produzione, questo campo non deve mai essere ignorato. Ignorare `max_tokens` porta a presentare risposte troncate senza indicazione che il testo è incompleto. Ignorare `tool_use` in un sistema agentico interrompe il loop, producendo risposte parziali che sembrano complete ma non lo sono.

## Esempi concreti

Un pattern per gestire lo streaming con rilevamento della fonte di stop, che discrimina i tre casi rilevanti in produzione:

```python
with client.messages.stream(
    model="claude-sonnet-4-6",
    max_tokens=2048,
    messages=messages
) as stream:
    full_response = stream.get_final_message()

if full_response.stop_reason == "max_tokens":
    print("[Risposta troncata — richiedi continuazione]")
elif full_response.stop_reason == "tool_use":
    # Estrai i blocchi tool_use e processali nel loop agentico
    tool_blocks = [b for b in full_response.content if b.type == "tool_use"]
    for tool in tool_blocks:
        result = execute_tool(tool.name, tool.input)
        # Invia il risultato come tool_result nel turno successivo
```

*(da Claude 101 — Claude 101)*

## Errori comuni e cosa evitare

Un errore frequente è abilitare lo streaming nelle interfacce utente senza gestire il caso di disconnessione. Se la connessione si interrompe a metà dello streaming, il testo parziale già visualizzato può essere confuso o fuorviante per l'utente. Una buona implementazione mostra un indicatore visivo di "generazione in corso" separato dal testo e gestisce esplicitamente l'errore di connessione — con un messaggio che indichi che la risposta è incompleta e offra la possibilità di riprovare. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic è un'estensione diretta di **Messages API: struttura e parametri** (stessa API, modalità diversa) ed è strettamente collegato a **Gestione errori e retry** (il troncamento da `max_tokens` e le disconnessioni richiedono strategie di retry specifiche). È anche collegato a **Tool Use (Function Calling)** (la gestione del `stop_reason == tool_use` in streaming) e ad **Agentic loop e autonomia** (dove lo streaming è usato per mostrare lo stato interno dell'agente all'utente durante l'esecuzione).