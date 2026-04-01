# Batch API

Aggiornato: April 1, 2026 9:14 AM
Categoria: API & Tools
Corsi: Claude 101
Stato: Completo

> 💬 La Batch API di Anthropic consente di processare grandi volumi di richieste in modo asincrono e con costi significativamente ridotti: è la scelta corretta per tutti i task non urgenti ad alto volume.
> 

## Cos'è e perché importa

Non tutti i task che richiedono il modello devono essere completati in tempo reale. Analisi di corpus documentali, valutazione di dataset, classificazione di grandi quantità di testo, generazione di report offline — tutti questi use case possono tollerare una latenza di ore in cambio di un risparmio economico sostanziale e di un accesso a quote più elevate. La Batch API è stata progettata esattamente per questo scenario. *(da Claude 101 — Claude 101)*

## Spiegazione

### Come funziona la Batch API

Invece di fare singole chiamate sincrone per ogni item da processare, con la Batch API si invia un file JSON contenente l'insieme delle richieste in un'unica operazione. Il sistema risponde con un `batch_id` che permette di monitorare lo stato dell'elaborazione. Il turnaround garantito è entro 24 ore, con l'obiettivo tipico di completamento molto prima. *(da Claude 101 — Claude 101)*

Il vantaggio economico è significativo: le chiamate batch vengono elaborate a un costo ridotto rispetto alle chiamate sincrone standard (tipicamente circa 50% di sconto), perché Anthropic può ottimizzare l'utilizzo dei propri cluster di calcolo distribuendo il carico nei momenti di minor traffico.

### Struttura di una richiesta batch

Ogni item nel batch è indipendente e ha la stessa struttura di una chiamata Messages API standard. Il sistema supporta la specifica di `custom_id` per ogni richiesta, facilitando il matching tra input e output al momento del recupero dei risultati. I risultati vengono restituiti in un file JSON con lo stesso `custom_id`, permettendo di riconciliare l'output con l'input originale anche in caso di ordine di completamento variabile. *(da Claude 101 — Claude 101)*

### Integrazione con il Prompt Caching

La Batch API è particolarmente efficiente quando combinata con il prompt caching: se tutte le richieste nel batch condividono lo stesso system prompt o lo stesso blocco di contesto, il caching elimina il costo di re-processare quel contenuto per ogni singola richiesta. *(da Claude 101 — Claude 101)*

## Esempi concreti

Un caso d'uso tipico è la classificazione di 10.000 review di prodotto in categorie predefinite. Invece di fare 10.000 chiamate sincrone (con rischio di rate limiting e costi elevati), si costruisce un batch con tutti gli item, si invia con la Batch API, si recuperano i risultati il giorno successivo. Il risparmio economico e la semplicità di gestione del rate limit rendono questa l'unica scelta ragionevole per questo tipo di pipeline. *(da Claude 101 — Claude 101)*

La struttura di ciascun item nel batch segue esattamente quella di una chiamata Messages API, con l'aggiunta del `custom_id` che permettere la riconciliazione nell'output:

```python
batch_requests = [
    {
        "custom_id": f"review-{i}",
        "params": {
            "model": "claude-haiku-4-5-20251001",  # Haiku per task semplici ad alto volume
            "max_tokens": 50,
            "messages": [
                {"role": "user", "content": f"Classifica questa review: {review_text}"}
            ]
        }
    }
    for i, review_text in enumerate(reviews)
]

# Invio del batch
response = client.beta.messages.batches.create(requests=batch_requests)
batch_id = response.id

# Recupero risultati (polling o webhook)
results = client.beta.messages.batches.results(batch_id)
for result in results:
    if result.result.type == "succeeded":
        print(f"{result.custom_id}: {result.result.message.content[0].text}")
    else:
        print(f"{result.custom_id}: errore - {result.result.error}")
```

## Errori comuni e cosa evitare

Un errore comune è usare la Batch API per task che richiedono risultati immediati — il turnaround di 24 ore non è adattabile a use case interattivi. Un secondo errore è non gestire i fallimenti parziali: la Batch API può completare alcune richieste e fallirne altre; il sistema di recupero dei risultati deve gestire esplicitamente i casi di errore per ogni `custom_id`. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic è collegato a **Messages API: struttura e parametri** (la Batch API usa la stessa struttura di richiesta), a **Prompt Caching** (la combinazione ottimale per ridurre i costi al massimo) e a **Gestione errori e retry** (la gestione dei fallimenti parziali nel batch).