# RLHF e Constitutional AI

Aggiornato: March 31, 2026 10:29 AM
Categoria: Ethics & Safety
Corsi: AI Fluency
Stato: Completo

> 💬 Il Reinforcement Learning from Human Feedback (RLHF) e il Constitutional AI sono i due pilastri tecnici dell'allineamento di Claude: il primo insegna al modello le preferenze umane tramite feedback diretto, il secondo aggiunge un sistema di principi espliciti che guidano l'autocritica durante il training.
> 

## Cos'è e perché importa

Addestrare un modello linguistico a produrre testo coerente e plausibile è un problema tecnicamente risolto. Addestrarlo a essere utile, onesto e sicuro è un problema molto più difficile, che richiede tecniche di allineamento specifiche. Senza queste tecniche, un modello capace può produrre contenuti accurati ma dannosi, persuasivi ma falsi, o semplicemente ottimizzati per rispondere in modo superficialmente soddisfacente invece che in modo genuinamente utile. RLHF e Constitutional AI sono le principali risposte di Anthropic a questo problema. *(da AI Fluency — AI Fluency)*

## Spiegazione

### RLHF: allineare il modello alle preferenze umane

Il Reinforcement Learning from Human Feedback funziona in tre fasi. Prima, il modello pre-addestrato genera risposte a diversi prompt. Poi, annotatori umani valutano queste risposte comparativamente — quale risposta è migliore e perché. Con queste valutazioni si addestra un modello di reward separato che apprende a predire la preferenza umana. Infine, il modello principale viene aggiornato tramite reinforcement learning per massimizzare il reward previsto da questo modello. Il risultato è un modello le cui risposte tendono ad allinearsi con le preferenze degli annotatori umani in modo sistematico. *(da AI Fluency — AI Fluency)*

RLHF ha dimostrato di migliorare significativamente l'utilità e la sicurezza dei modelli rispetto al solo pre-training, ma ha anche limitazioni: riflette i bias degli annotatori, non scala facilmente a domini specializzati, e non garantisce comportamenti sicuri in scenari non coperti dai dati di training.

### Constitutional AI: principi espliciti come guida

Constitutional AI è l'innovazione tecnica specifica di Anthropic. Invece di affidarsi esclusivamente al feedback umano implicito nelle valutazioni comparative, CAI introduce una "costituzione" — un insieme di principi etici espliciti scritti in linguaggio naturale — che il modello usa per auto-valutare e auto-correggere i propri output durante il training. *(da AI Fluency — AI Fluency)*

Il processo prevede che il modello generi una risposta, poi la critichi in base ai principi costituzionali, poi la riveda sulla base della critica. Questo ciclo di autocritica guidata dai principi avviene durante la fase di Reinforcement Learning, riducendo alla radice la generazione di contenuti dannosi o non etici invece di filtrarli a posteriori.

### I fondamenti della Costituzione di Anthropic

La costituzione di Claude è basata su documenti di riferimento etico consolidati, tra cui la Dichiarazione Universale dei Diritti Umani delle Nazioni Unite. Questo ancoraggio a un framework etico riconosciuto internazionalmente serve a dare ai principi una base non arbitraria e non legata esclusivamente alle preferenze del team di Anthropic. *(da AI Fluency — AI Fluency)*

### Collective Constitutional AI e l'evoluzione partecipativa

Una sviluppo recente è la Collective Constitutional AI: la ricerca che studia come incorporare una pluralità di prospettive nella definizione dei principi costituzionali, attraverso processi partecipativi che coinvolgono gruppi eterogenei di persone invece di affidarsi solo alle scelte del team. Un risultato concreto di questa ricerca è stato l'aggiunta di un principio specifico sul rispetto dei diritti delle persone con disabilità, derivato dalle indicazioni emerse dal processo partecipativo. *(da AI Fluency — AI Fluency)*

Questo approccio riflette una tesi fondamentale di Anthropic: che lo sviluppo responsabile dell'AI richiede il coinvolgimento di prospettive multidisciplinari e diverse, non può essere una decisione unilaterale di chi costruisce il sistema.

## Esempi concreti

Un esempio pratico dell'effetto di CAI: quando un utente chiede al modello di produrre contenuto che potrebbe essere dannoso in modo sottile o ambiguo, il modello non si limita a rifiutare meccanicamente in base a una lista di keyword vietate. Applica i principi costituzionali per ragionare sul perché la richiesta potrebbe essere problematica e risponde in modo contestuale, spiegando la propria posizione. Questo produce un comportamento molto più robusto e meno aggirabile rispetto ai sistemi basati su filtri a regole. *(da AI Fluency — AI Fluency)*

## Errori comuni e cosa evitare

Un malinteso comune è pensare che RLHF e CAI producano un modello "perfettamente allineato" che non può mai commettere errori etici. In realtà, entrambe le tecniche riducono significativamente certi tipi di problemi ma non li eliminano: il modello può ancora avere bias derivanti dai dati di training, può comportarsi in modo inatteso su scenari non rappresentati nel training, e i principi costituzionali sono comunque interpretabili in modo non univoco in casi limite. La comprensione di questi limiti è parte della "Diligence" del Framework 4D. *(da AI Fluency — AI Fluency)*

## Connessioni ad altri topic

Questo topic è la base tecnica di **Responsible use e bias** (dove i limiti dell'allineamento si traducono in responsabilità operativa), collegato a **Come funzionano i Large Language Model** (RLHF e CAI sono fasi del training del modello) e a **Sicurezza nei sistemi agentici** (come l'allineamento del modello base interagisce con i rischi specifici dei sistemi agentici).