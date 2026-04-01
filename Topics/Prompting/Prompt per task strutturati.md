# Prompt per task strutturati

Aggiornato: April 1, 2026 12:44 AM
Categoria: Prompting
Corsi: AI Fluency, Building with the Claude API, Claude 101
Stato: Completo

> 💬 I tag XML trasformano il prompt da testo libero a struttura semantica: separano esplicitamente le istruzioni dai dati, gli esempi dal contesto, rendendo il modello più affidabile e il comportamento più prevedibile su task complessi.
> 

## Cos'è e perché importa

Quando un prompt contiene molteplici componenti — istruzioni operative, dati di input, esempi di output atteso, contesto di background — il modello deve inferire dove finisce una sezione e dove inizia l'altra. Questa ambiguità è una fonte sistematica di errori: il modello può confondere un dato con un'istruzione, o un esempio con il valore reale su cui operare. I tag XML sono la soluzione tecnica a questo problema, non una convenzione stilistica. *(da Claude 101 — Claude 101)*

## Spiegazione

### I tag XML come separatori semantici

Claude è stato addestrato a trattare i tag XML come delimitatori di sezioni con significato distinto. L'uso di tag come `<instructions>`, `<example>`, `<data>`, `<context>`, `<output_format>` non è solo organizzativo: aiuta il modello a separare le diverse componenti semantiche del prompt con un meccanismo molto più robusto rispetto all'uso di semplici ritorni a capo o separatori testuali come `---`. *(da Claude 101 — Claude 101)*

Questo riduce le allucinazioni in due modi distinti. Il primo è che evita che il modello "mescoli" le istruzioni con i dati durante il processing. Il secondo è che rende esplicito il confine tra ciò che deve essere imitato (gli esempi nel tag `<examples>`) e ciò su cui deve essere eseguita l'azione (i dati nel tag `<data>`) — una distinzione che senza delimitatori espliciti il modello deve inferire dal contesto.

### Output strutturato e pipeline downstream

Per le applicazioni che consumano l'output di Claude in modo programmatico — un microservizio che si aspetta JSON, un sistema di estrazione che cerca pattern specifici — definire il formato dell'output nel prompt è essenziale. Un tag `<output_format>` con un esempio del JSON atteso, o con una descrizione esplicita della struttura, elimina la variabilità nel formato di risposta e rende l'integrazione molto più robusta. *(da Claude 101 — Claude 101)*

La stessa logica si applica al ragionamento intermedio: usare `<thinking>` per il processo di ragionamento e `<answer>` per la risposta finale permette di separare ciò che deve essere mostrato all'utente da ciò che serve solo come scaffolding interno. Per una trattazione completa di questa tecnica si rimanda al topic **Chain-of-thought e ragionamento esplicito**.

### Estrazione programmatica dalla risposta

Un'importante motivazione tecnica all'uso dei tag XML va oltre la separazione semantica in input: facilitare l'estrazione programmatica di sezioni specifiche dall'output. In un sistema di produzione, l'output di Claude viene spesso consumato da codice che deve estrarre parti strutturate — un JSON, un blocco di codice, una sezione specifica del testo. Racchiudere queste sezioni in tag XML predefiniti (es. `<json>`, `<reasoning>`, `<answer>`) permette all'applicazione di estrarle con semplici operazioni di parsing invece di dover analizzare l'intera risposta in testo libero. Questo rende l'integrazione molto più robusta rispetto all'analisi euristica del testo. *(da Building with the Claude API — Building with the Claude API)*

## Esempi concreti

Un prompt per l'estrazione di informazioni strutturate da testo libero illustra la separazione semantica nella sua forma più diretta:

```xml
<instructions>
Estrai le seguenti informazioni dal testo fornito e restituiscile in JSON.
Campi richiesti: nome, data, importo, valuta.
Se un campo non è presente, usa null.
</instructions>

<data>
Il contratto firmato il 15 marzo 2024 tra Mario Rossi e la società prevede
un compenso di 5.000 euro mensili a partire da aprile.
</data>
```

Questo formato garantisce che il modello non confonda le istruzioni di estrazione con il testo da analizzare. *(da Claude 101 — Claude 101)*

Un esempio più completo, tratto dal corso AI Fluency, mostra la combinazione di tutti e quattro i componenti chiave in un caso d'uso reale — analisi e categorizzazione di feedback clienti:

```xml
<instructions>
Analizza i seguenti feedback dei clienti e categorizzali per 'Sentimento' e 'Prodotto'.
Fornisci il risultato esclusivamente in formato JSON.
</instructions>

<context>
Siamo un'azienda di software che ha appena lanciato la versione 2.0.
</context>

<examples>
<example>
Input: "Il nuovo menu è confusionario."
Output: {"sentiment": "negativo", "product": "UI/UX"}
</example>
</examples>

<user_feedback>
{{FEEDBACK_TEXT}}
</user_feedback>
```

Il placeholder `{{FEEDBACK_TEXT}}` segna il punto di iniezione dell'input variabile: questa struttura è pensata per essere usata in una pipeline dove il placeholder viene sostituito programmaticamente prima dell'invio. *(da AI Fluency — AI Fluency)*

## Errori comuni e cosa evitare

Un errore comune è usare tag XML in modo inconsistente — a volte sì, a volte no, con nomi diversi per lo stesso tipo di contenuto — rendendo il prompt più confuso invece che più chiaro. La coerenza è importante: se si usa `<data>` per i dati di input, usarlo sempre e non alternarlo con `<input>` o `<text>`. Un secondo errore è annidare tag in modo eccessivamente profondo: la struttura deve servire la chiarezza, non diventare un esercizio di markup che richiede più sforzo cognitivo di quanto ne risparmi. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic è direttamente collegato a **Anatomia di un prompt efficace** (la struttura XML come implementazione pratica dei principi generali), a **Chain-of-thought e ragionamento esplicito** (l'uso dei tag `<thinking>` e `<answer>` per isolare il ragionamento dall'output finale) e a **Tool Use (Function Calling)** (dove l'output strutturato diventa input per funzioni esterne che si aspettano formato preciso).