# Messages API: struttura e parametri

Aggiornato: April 1, 2026 9:12 AM
Categoria: API & Tools
Corsi: AI Fluency, Building with the Claude API, Claude 101
Stato: Da Approfondire

> 💬 La Messages API è l'interfaccia principale per interagire con Claude in modo programmatico: comprendere la struttura delle richieste, i parametri chiave e il formato della risposta è il punto di partenza obbligatorio per qualsiasi integrazione.
> 

## Cos'è e perché importa

Ogni interazione con Claude tramite codice passa attraverso l'endpoint `/v1/messages`. Capire questa API non è solo una questione tecnica di sintassi: è comprendere il modello concettuale di come funziona una conversazione con Claude — una sequenza di turni alternati tra utente e assistente, all'interno di un contesto definito da un system prompt e da un insieme di parametri che controllano il comportamento del modello. *(da Claude 101 — Claude 101)*

## Spiegazione

### Struttura della richiesta

Una chiamata API minima comprende quattro parametri fondamentali. Il parametro `model` specifica l'identificatore del modello da usare (es. `claude-sonnet-4-6`). Il parametro `max_tokens` imposta il limite superiore di token che il modello può generare nella risposta — senza di esso la chiamata è invalida. Il parametro `messages` è un array di oggetti con campi `role` (user o assistant) e `content`, che rappresenta la cronologia della conversazione. Il parametro `system` contiene il system prompt, tecnicamente opzionale ma quasi sempre necessario in produzione. A questi si aggiunge `temperature`, che controlla il grado di stocasticità dell'output su una scala da 0 (deterministico) a 1 (massima variabilità). *(da Claude 101 — Claude 101)*

### Contenuto multimodale come array di blocchi

Un dettaglio architetturale importante riguarda il campo `content` nei messaggi: può essere sia una singola stringa (per input testuali semplici) sia un array di blocchi di contenuto distinti. La forma array è quella che abilita l'input multimodale — ogni blocco specifica il proprio tipo (`text`, `image`, `document`) e il contenuto corrispondente. Questo permette di combinare in un unico messaggio testo, screenshot, file PDF e altri formati, aprendo la strada ad applicazioni che analizzano documenti, estraggono informazioni da immagini o interpretano screenshot di interfacce. *(da Building with the Claude API — Building with the Claude API)*

### Vincolo di alternanza dei ruoli

Un vincolo architetturale critico è l'obbligo di alternare correttamente i ruoli `user` e `assistant`, iniziando sempre con un messaggio utente. Violare questa alternanza produce errori di validazione. In sistemi agentici con loop di tool use, è comune che lo sviluppatore debba costruire manualmente la history dei messaggi includendo sia i blocchi di risposta dell'assistente (con il blocco `tool_use`) sia il successivo messaggio utente (con il blocco `tool_result`), mantenendo l'alternanza corretta per tutta la durata del loop. *(da Building with the Claude API — Building with the Claude API)*

### L'SDK Python ufficiale

Anthropic fornisce un SDK Python che semplifica la gestione delle chiamate, inclusa la gestione automatica del retry su rate limit e la validazione dei parametri. Il pattern base per una chiamata semplice è il seguente:

```python
import os
from anthropic import Anthropic

client = Anthropic(api_key=os.environ.get("ANTHROPIC_API_KEY"))

message = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    system="Sei un architetto software esperto in sistemi agentici.",
    messages=[
        {"role": "user", "content": "Qual è il pattern più robusto per gestire il contesto in un agente?"}
    ]
)

print(message.content[0].text)
```

*(da Claude 101 — Claude 101)*

### La struttura della risposta

L'oggetto risposta contiene un array `content` — non una stringa singola — per supportare risposte multimodali e tool use. Per una risposta testuale semplice, il contenuto è in `message.content[0].text`. Il campo `stop_reason` indica come si è conclusa la generazione ed è critico per la gestione robusta delle risposte in produzione: i valori possibili (`end_turn`, `max_tokens`, `tool_use`) determinano azioni diverse nell'applicazione.

### Conteggio token e ottimizzazione dei costi

L'oggetto risposta include metadati sull'utilizzo dei token in `message.usage`: `input_tokens` (token consumati dal prompt) e `output_tokens` (token generati nella risposta). Monitorare questi valori è fondamentale per stimare i costi e ottimizzare le chiamate in sistemi ad alto volume. *(da Claude 101 — Claude 101)*

### Structured Outputs: supporto nativo per JSON schema

Da dicembre 2025, l'API supporta nativamente gli Structured Outputs con JSON schema su tutta la flotta di modelli. È possibile specificare nella chiamata uno schema JSON che l'output deve rispettare, e il modello garantisce la conformità strutturale. Prima di questa funzionalità, ottenere output JSON affidabile richiedeva una combinazione di istruzioni nel prompt e parsing con gestione degli errori. Gli Structured Outputs sono particolarmente rilevanti per pipeline di automazione e sistemi agentici dove l'output di Claude viene consumato programmaticamente da un componente downstream che si aspetta struttura precisa. *(da AI Fluency — AI Fluency)*

### Token Counting API

L'API espone un endpoint di token counting che permette di stimare il peso in token di una richiesta prima di inviarla, senza consumare quota di generazione né pagare per il processing. La prima utilità è la gestione preventiva dei rate limit: sapere in anticipo quanti token consuma ogni richiesta permette di distribuire il carico in modo ottimale in sistemi ad alto volume. La seconda è la stima preventiva dei costi: nei workflow agentici dove il numero di token varia significativamente tra i task, questa stima permette di implementare logiche di ottimizzazione — come scegliere un modello più economico per task leggeri — basate su dati concreti. *(da AI Fluency — AI Fluency)*

## Esempi concreti

Un pattern comune in produzione è costruire una funzione wrapper che gestisce automaticamente la conversazione multi-turno, accumulando la history dei messaggi e aggiungendo la risposta del modello prima di ogni nuovo turno:

```python
def chat(client, history: list, user_message: str, system: str) -> str:
    history.append({"role": "user", "content": user_message})
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=2048,
        system=system,
        messages=history
    )
    assistant_message = response.content[0].text
    history.append({"role": "assistant", "content": assistant_message})
    return assistant_message
```

La lista `history` accumula i turni mantenendo l'alternanza corretta, e la risposta del modello viene aggiunta come turno `assistant` prima del prossimo input utente. *(da Claude 101 — Claude 101)*

## Errori comuni e cosa evitare

L'errore più comune tra chi inizia è accedere a `message.content.text` come se fosse una stringa diretta: l'oggetto `content` è un array, e su risposte con tool use contiene blocchi di tipo diverso. Bisogna sempre accedere con `message.content[0].text` verificando il tipo del blocco, oppure iterare sull'intero array. Un secondo errore è non gestire il campo `stop_reason`: ignorarlo può portare a presentare all'utente risposte troncate senza indicazione che la generazione si è interrotta prematuramente, o a non eseguire la tool call che il modello ha richiesto. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic è la porta di ingresso a tutta l'area API & Tools: è prerequisito per **Streaming delle risposte** (variante asincrona della stessa API), **Tool Use (Function Calling)** (estensione del formato messaggi con blocchi `tool_use` e `tool_result`) e **Batch API** (variante per elaborazioni ad alto volume). È collegato anche a **Prompt Caching** (ottimizzazione del costo per system prompt statici) e a **Gestione errori e retry** (la gestione di `stop_reason` come segnale di errore o continuazione).