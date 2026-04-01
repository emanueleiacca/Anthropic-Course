# System prompt e separazione dei ruoli

Aggiornato: April 1, 2026 12:41 AM
Categoria: Prompting
Corsi: Claude 101
Stato: Da Approfondire

> 💬 Il system prompt non è solo una configurazione iniziale: è il meccanismo attraverso cui si definisce un'identità operativa persistente per il modello, separando il contesto fisso dall'input variabile dell'utente.
> 

## Cos'è e perché importa

In un'applicazione basata su Claude, distinguere tra ciò che rimane costante (il ruolo, le regole, il contesto di dominio) e ciò che varia ad ogni interazione (la richiesta specifica dell'utente) non è solo buona pratica ingegneristica: è una necessità funzionale. Senza questa separazione, ogni conversazione richiederebbe di "ricominciare da zero", ridefinendo contesto e regole di comportamento. Il system prompt è la soluzione tecnica a questo problema. *(da Claude 101 — Claude 101)*

La comprensione di questo meccanismo è prerequisito per qualsiasi applicazione non banale: dalle API integrate negli strumenti enterprise agli agent workflow più complessi.

## Spiegazione

### Il system prompt come guardrail persistente

A livello API, il parametro `system` nella chiamata ai Messages è il canale attraverso cui si definisce il comportamento del modello per tutta la durata della sessione. Il modello legge queste istruzioni prima di ogni risposta, il che le rende effettivamente persistenti. Un system prompt ben progettato definisce prima di tutto il ruolo che il modello deve incarnare, poi le regole di comportamento operative (cosa fare e cosa evitare in modo esplicito), il formato dell'output atteso e, quando rilevante, il contesto di dominio specifico come la documentazione aziendale o le linee guida di stile. Questi elementi non devono necessariamente essere separati con intestazioni, ma devono essere tutti presenti e coerenti. *(da Claude 101 — Claude 101)*

### Le Custom Instructions nei Progetti

Nell'interfaccia Claude, i Progetti offrono una implementazione ad alto livello del concetto di system prompt: le "Istruzioni Personalizzate" di un progetto funzionano esattamente come un system prompt persistente, applicato automaticamente a ogni conversazione aperta in quello spazio di lavoro. Questo permette di creare ambienti di lavoro specializzati dove il modello mantiene sempre la stessa coerenza stilistica e metodologica senza richiedere di ripetere il contesto ad ogni sessione. *(da Claude 101 — Claude 101)*

Un esempio pratico: un progetto per il team di engineering può avere istruzioni che specificano il linguaggio (Python 3.11+), le convenzioni di naming aziendali, il framework di testing preferito e le API interne che il codice deve saper usare. Ogni richiesta di codice in quel progetto sarà automaticamente coerente con questi vincoli.

### Separazione dei ruoli e sicurezza

La distinzione tra system prompt (operatore) e messaggio utente non è solo organizzativa: in sistemi multi-tenant o in applicazioni dove il prompt di sistema contiene istruzioni confidenziali, questa separazione crea un confine di sicurezza logico. Claude gestisce le istruzioni del system prompt con un livello di fiducia diverso rispetto alle istruzioni che arrivano nel turno utente, il che ha implicazioni importanti nella progettazione di applicazioni robuste e nella prevenzione di attacchi di prompt injection.

## Esempi concreti

Un pattern comune in produzione è creare system prompt modulari con sezioni ben distinte, così da poter aggiornare una sezione senza toccare le altre. Un esempio di struttura tipica per un assistente tecnico aziendale:

```
# Ruolo
Sei un assistente tecnico senior per il team di engineering di Acme Corp.
Operi su codebase Python 3.11+ con FastAPI e PostgreSQL.

# Regole operative  
- Segui sempre le convenzioni di naming definite nel nostro style guide.
- Quando proponi modifiche a file esistenti, mostra sempre il diff completo.
- Se una richiesta potrebbe causare breaking changes, segnalalo esplicitamente.

# Formato dell'output
Rispondi in italiano. Per il codice usa blocchi con syntax highlighting.
Per le spiegazioni usa prosa, non elenchi puntati.
```

Questa struttura è manutenibile, testabile sezione per sezione, e — grazie al prompt caching di Anthropic — può essere cachata e riusata tra chiamate successive riducendo sia la latenza sia il costo. *(da Claude 101 — Claude 101)*

## Errori comuni e cosa evitare

Un errore comune è mettere nel system prompt informazioni che dovrebbero stare nel messaggio utente (es. il contenuto specifico su cui lavorare ad ogni richiesta). Il system prompt dovrebbe contenere solo ciò che è costante tra le richieste; inserire dati variabili nel system prompt impedisce di sfruttare il prompt caching e appesantisce ogni chiamata con informazioni non sempre rilevanti. Un secondo errore è non testare il comportamento del modello quando le istruzioni del system prompt e le richieste dell'utente entrano in conflitto: è un caso che si verifica regolarmente in produzione e va gestito esplicitamente. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic è collegato direttamente a **Progetti e Artifacts** (l'implementazione ad alto livello del system prompt in Claude), a **Prompt Caching** (ottimizzazione del costo per system prompt lunghi e statici) e a **Sicurezza nei sistemi agentici** (la separazione dei ruoli come primo livello di difesa contro il prompt injection).