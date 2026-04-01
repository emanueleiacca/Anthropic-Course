# Prompt Caching

Aggiornato: April 1, 2026 9:17 AM
Categoria: API & Tools
Corsi: AI Fluency, Building with the Claude API, Claude 101
Stato: Completo

> 💬 Il prompt caching permette di riusare il prefisso computato di prompt lunghi e statici — system prompt, documentazione, codebase — riducendo sia la latenza sia il costo delle chiamate successive che condividono lo stesso contesto.
> 

## Cos'è e perché importa

In molte applicazioni, una porzione significativa di ogni chiamata API è identica: il system prompt aziendale, la documentazione di dominio, il contesto del progetto. Senza caching, questi token vengono re-processati ad ogni chiamata, moltiplicando i costi e la latenza in modo direttamente proporzionale al volume delle richieste. Il prompt caching di Anthropic risolve questo problema in modo trasparente: il prefisso statico del prompt viene computato una volta e riusato nelle chiamate successive, pagando il costo computazionale completo solo alla prima chiamata. *(da Claude 101 — Claude 101)*

Per applicazioni ad alto volume con system prompt lunghi — documentazione aziendale, knowledge base di dominio, configurazioni di Agent Skills estese — il risparmio può essere nell'ordine del 90% del costo del token di input.

## Spiegazione

### Come funziona il caching

Il meccanismo di caching si attiva quando una sequenza di token all'inizio della richiesta (il "prefisso") corrisponde a una sequenza già processata in una chiamata recente. Anthropic mantiene nella propria infrastruttura una cache dei prefissi computati per un periodo di tempo limitato: tipicamente 5 minuti per la cache standard, più lungo per le cache esplicite. Quando una nuova richiesta inizia con lo stesso prefisso, il costo di input per quei token è significativamente ridotto. *(da Claude 101 — Claude 101)*

### Cache esplicita con cache_control

Per controllare esattamente quali sezioni del prompt devono essere cachate, l'API supporta il campo `cache_control` sui blocchi di contenuto. Questo permette di marcare esplicitamente i blocchi da cachare — tipicamente il system prompt, documenti di riferimento statici, o larghe sezioni di contesto che non cambiano tra richieste:

```python
messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "text",
                "text": documentazione_aziendale,  # 50k token statici
                "cache_control": {"type": "ephemeral"}
            },
            {
                "type": "text",
                "text": domanda_utente  # input variabile, non cachato
            }
        ]
    }
]
```

*(da Claude 101 — Claude 101)*

### Caching a durata estesa: 1 ora per sessioni lunghe

La cache standard ha una durata di circa 5 minuti, sufficiente per pipeline ad alta frequenza dove le stesse richieste si ripetono in rapida successione. Il Prompt Caching a durata estesa, fino a 1 ora, è pensato per un caso d'uso diverso: sessioni di lavoro lunghe dove lo stesso contesto viene riusato nell'arco di un'ora intera. *(da AI Fluency — AI Fluency)*

Il caso emblematico è l'agente di sviluppo che lavora su un codebase: durante una sessione di un'ora, l'agente potrebbe rileggere gli stessi file sorgente, la stessa documentazione e le stesse convenzioni decine di volte. Con la cache estesa, il costo di processare quei token viene sostenuto una sola volta per tutta la sessione. L'impatto economico per agenti con cicli iterativi intensi su contenuto stabile è molto significativo.

### Context Compaction: tecnica complementare al caching

La Context Compaction è una tecnica complementare al Prompt Caching per gestire conversazioni molto lunghe che si avvicinano al limite dei token. Invece di dipendere dal caching del prefisso (ottimale per contenuto statico), la Context Compaction prevede che un processo in background riassuma periodicamente i turni più vecchi della conversazione, preservando le decisioni chiave e scartando i dettagli contestuali non più rilevanti. Il riassunto compatto sostituisce i turni originali nella history, mantenendo il sistema efficiente nel lungo periodo. *(da Building with the Claude API — Building with the Claude API)*

Le due tecniche si applicano a scenari distinti: il Prompt Caching è ottimale per contenuto statico che si ripete tra chiamate distinte (system prompt, documenti di riferimento, basi di codice), mentre la Context Compaction è ottimale per conversazioni con stato che crescono nel tempo all'interno di una singola sessione agentica lunga. In sistemi agentici complessi, entrambe le tecniche vengono usate in combinazione.

### Integrazione con la Batch API

La combinazione più efficiente è prompt caching + Batch API per task offline ad alto volume: il caching riduce il costo dei token statici, la Batch API riduce il costo delle chiamate. Se un batch di 1000 richieste condivide lo stesso system prompt da 10k token, il caching elimina il costo di processare quei 10k token 999 volte su 1000. *(da Claude 101 — Claude 101)*

## Esempi concreti

Un'applicazione di supporto tecnico con una knowledge base di 50.000 token (manuale prodotto, FAQ, procedure) inviata come contesto in ogni chiamata risparmia circa il 90% del costo dei token di input per tutte le richieste successive alla prima nel periodo di caching. Su volumi di 10.000 chiamate al giorno, il risparmio mensile può essere nell'ordine di centinaia di dollari. *(da Claude 101 — Claude 101)*

Per verificare che il caching stia funzionando, l'oggetto risposta espone il campo `cache_read_input_tokens` nell'oggetto `usage`. Un valore maggiore di zero conferma che il prefisso è stato letto dalla cache invece di essere riprocessato — e quindi che si sta pagando il costo ridotto per quei token.

## Errori comuni e cosa evitare

Un errore comune è posizionare il contenuto da cachare alla fine del prompt invece che all'inizio. Il caching funziona sul prefisso: se il contenuto statico si trova dopo contenuto variabile, il prefisso cambia ad ogni richiesta e il cache miss è garantito. La struttura corretta è sempre: contenuto statico (system prompt, documentazione) prima, contenuto variabile (input utente) dopo. Un secondo errore è non monitorare il campo `cache_read_input_tokens` nella risposta per verificare se il caching sta effettivamente funzionando — senza questo controllo, si potrebbe continuare a pagare il costo pieno senza accorgersene. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic è collegato a **Messages API: struttura e parametri** (il caching è una funzionalità dell'API Messages configurata nei blocchi di contenuto), a **Batch API** (la combinazione ottimale per ridurre i costi al massimo), a **Progetti e Artifacts** (i file caricati nei Progetti beneficiano implicitamente del caching) e a **System prompt e separazione dei ruoli** (il system prompt come candidato primario al caching, essendo il contenuto più stabile tra le chiamate).