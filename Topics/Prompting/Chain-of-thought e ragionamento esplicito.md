# Chain-of-thought e ragionamento esplicito

Aggiornato: April 1, 2026 12:43 AM
Categoria: Prompting
Corsi: AI Fluency, Building with the Claude API, Claude 101
Stato: Completo

> 💬 Chiedere al modello di esplicitare i passaggi intermedi del suo ragionamento non è solo una tecnica didattica: è un meccanismo che migliora strutturalmente la qualità delle risposte su task complessi, e nei modelli recenti è diventato una funzionalità configurabile.
> 

## Cos'è e perché importa

I modelli linguistici producono token in sequenza, e la qualità di ciascun token dipende da tutti quelli precedenti. Quando il modello "pensa ad alta voce" — esplicitando i passaggi intermedi prima di arrivare alla risposta — ogni step successivo beneficia della maggiore precisione dei passaggi precedenti. Questo è il motivo per cui il chain-of-thought non è semplicemente un modo per rendere le risposte più trasparenti, ma un meccanismo che migliora l'accuratezza in modo misurabile, in particolare su task di ragionamento matematico, logico o multi-step. *(da Claude 101 — Claude 101)*

## Spiegazione

### Chain-of-thought tradizionale

La tecnica classica consiste nell'aggiungere al prompt istruzioni come "ragiona step by step prima di rispondere" o "prima di dare la risposta finale, mostra il tuo ragionamento". Nei modelli moderni questa è sufficiente per attivare il comportamento desiderato. Un pattern più robusto usa i tag XML per separare esplicitamente la sezione di ragionamento dalla risposta finale: il tag `<thinking>` raccoglie il ragionamento intermedio, il tag `<answer>` contiene la risposta definitiva da consumare downstream. La separazione è importante perché il testo di ragionamento — con le sue esitazioni, revisioni e tangenti — non è sempre adatto ad essere presentato all'utente. *(da Claude 101 — Claude 101)*

### Extended Thinking nativo: da Claude 3.7 in poi

A partire da Claude 3.7 Sonnet, l'Extended Thinking è una funzionalità nativa configurabile tramite il parametro `thinking` nella chiamata API. Quando abilitato, il modello esegue un processo di ragionamento interno — non visibile nel testo dell'output finale, ma accessibile come blocchi di pensiero separati — prima di generare la risposta. Questo rappresenta un cambio architetturale rispetto al CoT tradizionale: il ragionamento non è nel prompt, ma è gestito nativamente dal modello con meccanismi di auto-correzione interni. La funzionalità è disponibile su tutta la serie Claude 3.7+ e Claude 4. *(da Claude 101 — Claude 101)*

Il parametro `budget_tokens` permette di controllare quanti token il modello può dedicare al ragionamento interno, bilanciando profondità di analisi e costo. Impostare un budget troppo basso limita il ragionamento su task complessi; un budget troppo alto aumenta latenza e costo senza necessariamente migliorare l'output su task semplici. La calibrazione deve essere guidata dalla complessità del task, non da un valore di default applicato uniformemente. *(da AI Fluency — AI Fluency)*

### L'anti-pattern dell'over-prompting

Un punto critico riguarda l'interazione tra chain-of-thought e la tendenza all'over-prompting. Fornire istruzioni eccessivamente prescrittive ("Step 1: fai X; Step 2: fai Y") a modelli potenti interferisce con la loro capacità di pianificare autonomamente il ragionamento. Il risultato paradossale è che istruzioni più dettagliate producono spesso output di qualità inferiore rispetto a un obiettivo chiaro accompagnato dalla libertà di ragionare. La tecnica corretta è definire il risultato atteso con precisione, non il percorso per raggiungerlo. *(da Claude 101 — Claude 101)*

### Reasoning Audit: ispezionare il processo prima dell'output

Con i modelli che supportano Extended Thinking nativo, il discernimento si sposta dall'output al processo. I blocchi di pensiero — la sequenza di ragionamento interno che il modello produce prima della risposta finale — diventano accessibili e ispezionabili dall'utente o dal sistema. Invece di valutare solo se la risposta è corretta, è possibile verificare se il percorso logico che ha portato a quella risposta è coerente e privo di errori. *(da AI Fluency — AI Fluency)*

Il Reasoning Audit è particolarmente importante per task ad alto rischio — analisi finanziarie, ragionamento legale, decisioni mediche. Un errore di logica nel processo di pensiero può portare a una risposta che suona convincente ma è basata su un'inferenza sbagliata. Il Reasoning Audit permette di intercettare questo tipo di errore prima che si traduca in un'azione con conseguenze reali.

### Extended Thinking nei framework di valutazione

Il corso Building with the Claude API inquadra l'Extended Thinking anche come componente di sistemi di valutazione sistematici. Nei framework di eval, i modelli con Extended Thinking vengono testati su task di ragionamento complesso dove il processo di pensiero intermedio è parte del deliverable da valutare, non solo la risposta finale. Questo permette di misurare la qualità del ragionamento separatamente dalla qualità della risposta — identificando i casi in cui il modello arriva alla risposta giusta per le ragioni sbagliate, un tipo di errore invisibile senza l'ispezione del processo. *(da Building with the Claude API — Building with the Claude API)*

## Esempi concreti

Per task di analisi architetturale, un pattern efficace che sfrutta i tag XML per strutturare il ragionamento:

```xml
<task>
Analizza la seguente architettura e identifica i potenziali colli di bottiglia.
Prima sviluppa il tuo ragionamento in modo esplicito, poi fornisci le raccomandazioni.
</task>
<thinking>
[Il modello svilupperà qui il ragionamento intermedio, visibile per audit]
</thinking>
<recommendations>
[Raccomandazioni finali, più precise grazie al ragionamento esplicito precedente]
</recommendations>
```

*(da Claude 101 — Claude 101)*

## Errori comuni e cosa evitare

Un errore frequente è usare il chain-of-thought su tutti i task indiscriminatamente. Per task semplici e ben definiti — classificazione binaria, estrazione di un campo specifico, traduzione diretta — il ragionamento esplicito è overhead inutile che aumenta la latenza e il costo senza migliorare il risultato. È una tecnica da riservare ai task dove il modello potrebbe "sbagliare strada" senza riflessione guidata, tipicamente task multi-step, ambigui, o che richiedono pianificazione. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic è strettamente collegato a **Anatomia di un prompt efficace** (il CoT come tecnica dentro una struttura di prompt più ampia), a **Temperature e parametri di generazione** (come il campionamento interagisce con il ragionamento) e a **Agentic loop e autonomia** (dove il ragionamento step-by-step diventa il fondamento del loop agentico). Il Reasoning Audit connette questo topic a **Allucinazioni e verifica dei fatti** (l'ispezione del processo come strumento di verifica).