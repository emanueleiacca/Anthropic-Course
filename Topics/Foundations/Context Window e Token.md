# Context Window e Token

Aggiornato: April 1, 2026 9:20 AM
Categoria: Foundations
Corsi: AI Fluency, Claude 101, Intro to Agent Skills, Intro to Claude Cowork
Stato: Da Approfondire

> 💬 La context window è il limite entro cui il modello può "vedere" e ragionare in una singola inferenza; capire come viene conteggiata e gestita è essenziale per costruire applicazioni affidabili e per sfruttare le funzionalità avanzate come i Progetti.
> 

## Cos'è e perché importa

Ogni chiamata a Claude ha una quantità finita di informazioni che il modello può considerare simultaneamente: questa finestra è misurata in token, le unità minime in cui il testo viene scomposto prima dell'elaborazione. Un token corrisponde approssimativamente a tre-quattro caratteri in italiano o a tre-quarti di una parola inglese media, ma la granularità varia a seconda del tokenizer. Ciò che conta dal punto di vista progettuale è che sia il testo inviato (input) sia il testo generato (output) consumano token dalla stessa finestra, e superare il limite produce un errore o un troncamento silenzioso. *(da Claude 101 — Claude 101)*

La context window non è solo un limite tecnico: è un vincolo architetturale che determina cosa è possibile fare in un'unica interazione e cosa invece richiede strategie di gestione esplicita del contesto.

## Spiegazione

### Token: l'unità di misura

Il concetto di token è fondamentale per stimare i costi e prevenire errori. I modelli Claude moderni (famiglia 3 e successive) supportano finestre di contesto molto ampie — fino a 200.000 token nei Progetti Claude — il che equivale approssimativamente a 150.000 parole, ovvero un romanzo di medie dimensioni. Questa capacità ha reso praticabile l'analisi di interi codebase o di documenti lunghi in un'unica sessione. *(da Claude 101 — Claude 101)*

### I Progetti e la gestione del contesto persistente

Nell'interfaccia Claude, i Progetti offrono una finestra di contesto dedicata da 200.000 token all'interno della quale è possibile caricare fino a 20 file di diversi formati (PDF, DOCX, CSV e altri). Questi file vengono mantenuti persistentemente nel contesto del progetto e non è necessario ricaricarli ad ogni nuova conversazione. Questo meccanismo trasforma il modello da strumento conversazionale a sistema con "memoria di lavoro" su un corpus di documenti specifico. *(da Claude 101 — Claude 101)*

### Implicazioni architetturali: finestra ampia e fenomeno "lost in the middle"

La scelta del modello influenza direttamente la finestra disponibile, e questo ha conseguenze progettuali non banali. Per task che richiedono l'analisi simultanea di grandi quantità di testo — confronto tra versioni di un documento, revisione di un intero codebase — la finestra ampia di Claude è un vantaggio competitivo significativo rispetto ad approcci tradizionali basati su chunking aggressivo.

D'altra parte, una finestra grande non equivale a prestazioni uniformi su tutto il contesto. I modelli tendono a prestare maggiore attenzione ai contenuti all'inizio e alla fine della finestra, mentre i contenuti nel "mezzo" di un contesto molto lungo rischiano di essere trattati con minore precisione. Questo fenomeno, noto come "lost in the middle", è rilevante quando si caricano molti file nel contesto di un Progetto ed è uno dei motivi per cui la qualità del contesto conta quanto la quantità. *(da Claude 101 — Claude 101)*

### Prompt Caching a durata estesa: ottimizzazione per sessioni lunghe

Un aggiornamento significativo dell'ecosistema Anthropic è il Prompt Caching con durata estesa fino a 1 ora. Il caso d'uso emblematico è un agente che lavora su un codebase: se deve consultare la stessa documentazione o gli stessi file sorgente più volte nell'arco di una sessione, il caching esteso garantisce che questi token non vengano riprocessati ad ogni chiamata, riducendo drasticamente sia la latenza sia il costo. A differenza del caching standard (circa 5 minuti), la versione estesa è pensata per sessioni di lavoro prolungate dove lo stesso contesto viene riusato nell'arco di un'ora intera. *(da AI Fluency — AI Fluency)*

### Token counting API: stima granulare prima dell'invio

La token counting API permette di stimare il numero di token di una richiesta prima di inviarla, senza consumare quota di generazione. Questo ha due utilità pratiche principali. La prima è la gestione granulare dei rate limit: in sistemi ad alto volume, sapere in anticipo il peso in token di ogni richiesta permette di distribuire il carico in modo ottimale senza incorrere in errori 429. La seconda è la stima preventiva dei costi: in workflow agentici dove il numero di token varia significativamente tra i task, la stima preliminare permette di scegliere il modello più appropriato per ogni richiesta in base a dati concreti invece che su stime approssimative. *(da AI Fluency — AI Fluency)*

### Token overhead dei server MCP e on-demand tool loading

Un aspetto operativo critico riguarda il costo in token delle definizioni degli strumenti MCP. Ogni server MCP connesso espone una lista di tool, e ogni definizione di tool (con il suo schema JSON) consuma token nella finestra di contesto ancora prima che l'utente inserisca il proprio prompt. I server MCP più ricchi di funzionalità possono essere molto costosi in questo senso: il server ufficiale di GitHub espone circa 40 tool e quello di Linear circa 27, arrivando insieme a consumare circa l'8.5% dell'intera finestra da 200k token. Con più server attivi contemporaneamente, questo overhead si accumula rapidamente. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

La soluzione raccomandata è il pattern di on-demand tool loading: invece di attivare tutti i server MCP all'avvio, un planner seleziona e attiva solo gli strumenti strettamente necessari per il task corrente. Questo mantiene basso l'overhead e riduce la probabilità che il modello scelga il tool sbagliato — meno opzioni significano meno ambiguità nella selezione.

### Progressive Disclosure nelle Skills: tre livelli di caricamento

Il pattern di progressive disclosure applicato alle Agent Skills è il meccanismo con cui una libreria anche molto ampia di competenze può coesistere senza saturare la context window. Al primo livello, quello della scoperta, vengono caricati solo i metadati di ogni Skill — nome e descrizione — con un footprint medio di circa 100 token per Skill. Una libreria di 20 Skills occupa quindi circa 2.000 token, un overhead accettabile anche in conversazioni con budget ridotto. *(da Introduction to Agent Skills — Intro to Agent Skills)*

Quando Claude identifica che il task corrente corrisponde a una Skill specifica, scatta il secondo livello: il contenuto completo del file [SKILL.md](http://SKILL.md) viene iniettato nel contesto. Per mantenere alta la qualità dell'attenzione, questo file non dovrebbe superare le 500 righe — oltre questa soglia il modello fatica a seguire accuratamente tutte le istruzioni. Il terzo livello avviene solo se le istruzioni del [SKILL.md](http://SKILL.md) puntano a risorse aggiuntive come manuali in `/references` o script in `/scripts`: Claude vi accede solo nel momento esatto in cui servono, usando i propri tool. Un manuale tecnico di migliaia di righe ha quindi impatto zero sulla finestra di contesto fino al momento del suo utilizzo effettivo.

## Esempi concreti

Un esempio pratico di gestione persistente: caricare in un Progetto le linee guida di stile aziendale, la documentazione delle API interne e i file di configurazione del progetto significa che ogni richiesta di generazione di codice avverrà sempre nel contesto di quella documentazione, senza doverla incollare manualmente nel prompt. La persistenza del contesto è gestita automaticamente dalla piattaforma. *(da Claude 101 — Claude 101)*

Per dare un senso concreto alla token counting API: una richiesta con un system prompt di 2.000 token, una documentazione di riferimento di 15.000 token e un messaggio utente di 500 token ha un input totale di 17.500 token. Con un modello che costa $3 per milione di token di input, questa singola richiesta costa circa $0.05. Se la stessa richiesta viene eseguita 1.000 volte al giorno su un corpus statico, il prompt caching riduce il costo effettivo dei 15.000 token di documentazione (la parte che non cambia) di circa il 90%.

## Errori comuni e cosa evitare

Un errore tipico è caricare decine di file irrilevanti nel contesto di un Progetto pensando che "più contesto è sempre meglio". In realtà, riempire la context window con materiale non pertinente aumenta il rumore e può portare il modello a trascurare dettagli critici sepolti in mezzo a informazioni superflue. La diluizione dell'attenzione è uno degli anti-pattern più documentati nei sistemi agentici reali: l'accumulo indiscriminato di contesto degrada la qualità delle risposte in modo non intuitivo. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic è alla base di **Modelli Claude: famiglie e differenze** (ogni modello ha una finestra diversa), di **Prompt Caching** (ottimizzare il costo delle chiamate con contesti lunghi e statici), di **Context management nel codice** (strategie pratiche per gestire la finestra in Claude Code) e di **Agent Skills in Claude Code** (la progressive disclosure come strategia di gestione del contesto nelle Skills).