# Few-shot prompting

Aggiornato: April 1, 2026 12:42 AM
Categoria: Prompting
Corsi: AI Fluency, Building with the Claude API, Claude 101
Stato: Da Approfondire

> 💬 Il few-shot prompting guida il modello per analogia: fornire esempi ben scelti è spesso più efficace di istruzioni elaborate, ma la qualità e la diversità degli esempi determinano la qualità dell'output in modo critico.
> 

## Cos'è e perché importa

I modelli linguistici apprendono per pattern. Il few-shot prompting sfrutta questa caratteristica in modo diretto: invece di descrivere astrattamente cosa si vuole, si mostrano esempi concreti di input e output desiderato. Il modello generalizza dalla struttura degli esempi e applica lo stesso pattern all'input reale. È una tecnica che funziona su un'ampia gamma di task ed è spesso il modo più rapido per ottenere output nel formato e nello stile precisi richiesti, senza dover modificare il system prompt o aggiungere istruzioni complesse. *(da AI Fluency — AI Fluency)*

## Spiegazione

### Struttura del few-shot prompting

Un prompt few-shot include una serie di coppie input-output che dimostrano il comportamento desiderato, seguita dall'input reale su cui il modello deve operare. Il numero di esempi ("shot") può variare: zero-shot significa nessun esempio (solo istruzioni), one-shot un singolo esempio, few-shot tipicamente 2-5 esempi. Per la maggior parte dei task, 2-3 esempi ben scelti producono risultati comparabili a quantità maggiori, a fronte di un costo in token molto inferiore.

### Diversità degli esempi: il principio critico

La selezione degli esempi non è neutra. Gli esempi devono essere diversi tra loro per coprire i casi limite e per evitare che il modello identifichi pattern non intenzionali. *(da AI Fluency — AI Fluency)*

Se tutti gli esempi hanno la stessa struttura sintattica, la stessa lunghezza o lo stesso tono, il modello potrebbe trattare queste caratteristiche come vincoli impliciti dell'output invece che come coincidenze. Per esempio, in un task di classificazione del sentiment, includere solo esempi di testi brevi porta il modello a produrre classificazioni molto brevi anche su input lunghi, anche se non è questo il comportamento desiderato.

### Uso con i tag XML

In combinazione con i tag XML, il few-shot prompting diventa molto più preciso. Gli esempi possono essere racchiusi in tag `<example>` che li delimitano chiaramente dal contesto e dall'input reale, riducendo il rischio che il modello confonda gli esempi con i dati su cui operare. *(da AI Fluency — AI Fluency)*

```xml
<examples>
  <example>
    <input>Il nuovo menu è confusionario.</input>
    <output>{"sentiment": "negativo", "categoria": "UI/UX"}</output>
  </example>
  <example>
    <input>La consegna è arrivata in anticipo, ottimo!</input>
    <output>{"sentiment": "positivo", "categoria": "logistica"}</output>
  </example>
</examples>
```

### Quando preferire il few-shot al prompting descrittivo

Il few-shot eccelle in tutti quei casi in cui il formato o lo stile dell'output sono più facili da mostrare che da descrivere. Se il modello deve riprodurre lo stile di un documento aziendale esistente, mostrare due o tre estratti produce risultati migliori di qualsiasi descrizione verbale dello stile. Lo stesso vale per la terminologia tecnica di dominio: gli esempi trasmettono sfumature di significato che le istruzioni astratte difficilmente catturano.

Il few-shot è invece meno efficace quando gli esempi disponibili non coprono la varietà dell'input reale — in quel caso il modello generalizza dai pattern degli esempi in modo che potrebbe non essere desiderabile. È anche meno indicato per task che richiedono ragionamento profondo piuttosto che imitazione di stile: in quei casi la chain-of-thought è più appropriata, e le due tecniche possono essere combinate includendo il ragionamento intermedio direttamente negli esempi.

### Generazione di dataset di test con modelli più potenti

Il corso Building with the Claude API introduce una prospettiva che estende il few-shot oltre il prompting: l'uso di modelli potenti come Claude Opus per generare dataset di casi di test realistici ed edge cases da usare nei framework di valutazione sistematica. In questo contesto, gli esempi few-shot non sono solo istruzioni nel prompt, ma anche la materia prima per costruire pipeline di eval. I casi di test generati da Opus vengono usati per valutare automaticamente la qualità delle risposte del modello in produzione, creando un ciclo di miglioramento continuo basato su dati invece che su intuizioni. *(da Building with the Claude API — Building with the Claude API)*

## Esempi concreti

Un caso classico è la classificazione di feedback clienti. Invece di scrivere una lunga descrizione delle categorie e dei criteri di classificazione, si forniscono 3-4 esempi rappresentativi che coprono sentiment positivo, negativo e neutro, e tipi di problema diversi — prodotto, servizio, logistica. Il modello inferisce i criteri dagli esempi con maggiore precisione di quanto farebbe da una descrizione astratta, perché gli esempi trasmettono non solo le categorie ma anche le sfumature che determinano l'appartenenza a ciascuna. *(da AI Fluency — AI Fluency)*

## Errori comuni e cosa evitare

Un errore frequente è usare esempi troppo simili tra loro. Se tutti e tre gli esempi mostrano feedback negativi brevi su problemi di prodotto, il modello applicherà implicitamente questi pattern come regole implicite: classificherà come "problema di prodotto" anche feedback che non lo sono, o abbrevierà output che dovrebbero essere più articolati. La regola pratica è che gli esempi devono coprire almeno le dimensioni di variabilità più importanti del task reale. *(da AI Fluency — AI Fluency)*

Un secondo errore è dimenticare di includere casi limite negli esempi. Se il task prevede input ambigui, nulli o mal formati, è importante includere almeno un esempio che mostri come gestirli — altrimenti il modello improvviserà su questi casi in modo non prevedibile, e spesso in modo incoerente rispetto al comportamento desiderato.

## Connessioni ad altri topic

Questo topic è la continuazione diretta di **Anatomia di un prompt efficace** (il few-shot come tecnica strutturale del prompt) e complementare a **Prompt per task strutturati** (i tag XML come contenitori degli esempi). È collegato a **Chain-of-thought e ragionamento esplicito** (negli esempi few-shot si può includere il ragionamento intermedio oltre all'output, combinando le due tecniche) e a **Evaluation-driven development** (gli esempi few-shot come materia prima per le pipeline di valutazione).