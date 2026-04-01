# Come funzionano i Large Language Model

Aggiornato: April 1, 2026 12:25 AM
Categoria: Foundations
Corsi: AI Fluency, Claude 101
Stato: Da Approfondire

> 💬 Un LLM è una rete neurale basata sull'architettura Transformer, addestrata a predire il token successivo su enormi corpus testuali: da questo compito apparentemente semplice emergono capacità linguistiche e di ragionamento che trascendono la semplice statistica, e che Anthropic ha ulteriormente plasmato attraverso tecniche di allineamento specifiche.
> 

## Cos'è e perché importa

Capire come funziona un LLM a livello concettuale non è un esercizio teorico: è la base per comprendere perché certi comportamenti si verificano (e altri no), perché le tecniche di prompting funzionano, e quali sono i limiti intrinseci del sistema con cui si sta lavorando. Senza questo fondamento, si rischia di attribuire a "magia" o "bug" ciò che è invece un comportamento prevedibile e comprensibile. Un modello che "allucinazioni" non è rotto — sta facendo esattamente quello per cui è stato addestrato, ovvero produrre sequenze di token plausibili, anche quando non ha le informazioni necessarie per farlo correttamente. *(da Claude 101 — Claude 101)*

Comprendere questo framework aiuta anche a progettare system prompt e workflow che lavorano con la natura del modello invece di lavorarci contro: sapere che Claude è stato addestrato a resistere a certe categorie di istruzioni, a segnalare l'incertezza e a rifiutare task dannosi permette di anticipare il comportamento invece di essere sorpresi da esso.

## Spiegazione

### L'architettura Transformer e il meccanismo di attenzione

I modelli Claude sono basati sull'architettura Transformer, introdotta nel 2017 con il paper "Attention is All You Need". Il componente centrale è il meccanismo di self-attention: per ogni token generato, il modello calcola quanto "peso" dare a ciascuno degli altri token nel contesto corrente. Questo permette di catturare dipendenze a lungo raggio nel testo — collegare un pronome al suo referente molte frasi prima, riconoscere la struttura argomentativa di un documento lungo, mantenere la coerenza tematica attraverso migliaia di token — in modo molto più efficace delle architetture precedenti basate su reti ricorrenti. *(da AI Fluency — AI Fluency)*

La generazione avviene token per token: il modello riceve la sequenza corrente, calcola una distribuzione di probabilità sul vocabolario intero, e campiona il token successivo da quella distribuzione. I parametri di campionamento come la temperatura determinano quanto la scelta è deterministica o variabile. Questo processo si ripete fino al raggiungimento di una condizione di stop.

### Le due fasi del training: pre-training e fine-tuning

L'addestramento avviene in due fasi principali con obiettivi distinti. Il pre-training espone il modello a enormi corpus testuali — pagine web, libri, codice, articoli scientifici — e lo addestra su un unico obiettivo: predire il token successivo in una sequenza. Da questo compito emerge, come proprietà emergente, una comprensione statistica profonda del linguaggio, della logica, dei fatti del mondo e delle relazioni tra concetti. Il modello non viene programmato con regole: le inferisce dai pattern nei dati. *(da AI Fluency — AI Fluency)*

Il fine-tuning successivo trasforma questo modello capace ma indisciplinato in un assistente utile e sicuro. Le tecniche principali sono il Reinforcement Learning from Human Feedback (RLHF), che allinea le risposte alle preferenze umane attraverso un processo di valutazione comparativa, e il Constitutional AI di Anthropic, descritto nella sezione successiva.

### La filosofia Anthropic: utile, onesto e innocuo come principi di ingegneria

Anthropic differenzia il proprio approccio attraverso la Constitutional AI: invece di affidarsi esclusivamente al feedback umano implicito nelle valutazioni comparative, introduce una "costituzione" — un insieme di principi etici espliciti basati su documenti come la Dichiarazione Universale dei Diritti Umani dell'ONU — che il modello usa per auto-valutare e auto-correggere i propri output durante il training. Questo meccanismo agisce durante la fase di Reinforcement Learning, riducendo alla radice la generazione di contenuti problematici invece di filtrarli a posteriori. *(da Claude 101 — Claude 101)*

I tre principi fondativi — essere utile (helpfulness), essere onesto (honesty) e non causare danni (harmlessness) — non sono solo enunciati etici: sono stati incorporati nel processo di training al punto che Claude resiste a istruzioni che li violano anche quando formulate in modo sofisticato, segnala l'incertezza invece di inventare risposte, e rifiuta task dannosi invece di eseguirli meccanicamente.

Recentemente, Anthropic ha sviluppato la Collective Constitutional AI: una ricerca che studia come incorporare prospettive multidisciplinari e diverse nella definizione dei principi costituzionali attraverso processi partecipativi, invece di affidarsi solo alle scelte del team interno. Un risultato concreto è stato l'aggiunta di un principio sul rispetto dei diritti delle persone con disabilità, emerso dal processo partecipativo. *(da AI Fluency — AI Fluency)*

## Esempi concreti

Il modo più intuitivo per capire la predizione del token successivo è osservare come il modello completa frasi parziali. Data la sequenza "La capitale della Francia è", il modello assegna probabilità altissima al token "Parigi" e probabilità quasi nulla a qualsiasi altro token — non perché abbia "cercato" questa informazione, ma perché ha visto milioni di volte questa associazione nei dati di training. Data invece la sequenza "La capitale della Francia è conosciuta per la sua", il modello distribuisce le probabilità su molti token plausibili (torre, cucina, moda, arte...) perché tutti appaiono frequentemente in questo contesto. La temperatura controlla esattamente questa distribuzione: bassa temperatura seleziona quasi sempre il token più probabile; alta temperatura rende i token meno probabili più competitivi.

Un secondo esempio riguarda il meccanismo di attenzione applicato alla coerenza a lungo raggio. In un documento di 10.000 token, quando il modello genera il pronome "lui" al token 9.847, l'attenzione permette di risalire al soggetto maschile introdotto al token 23 e mantenere la coerenza. Le architetture ricorrenti precedenti dovevano "ricordare" questa informazione attraverso migliaia di step intermedi — una sfida analoga al telefono senza fili, dove il messaggio si degrada ad ogni passaggio.

## Errori comuni e cosa evitare

L'errore concettuale più frequente è antropomorfizzare il modello: attribuirgli intenzioni, credenze o emozioni nel senso in cui le ha un essere umano. Claude non "vuole" risponderti, non "sa" di stare sbagliando, non "sente" frustrazione. Questi sono pattern linguistici che il modello produce perché appaiono frequentemente nel testo umano — non stati interni. Questa distinzione è importante perché porta a prompt più efficaci: invece di "puoi per favore provare a essere più preciso?", è più efficace specificare il formato atteso o i criteri di qualità in modo esplicito.

Un secondo errore è confondere la competenza linguistica con la conoscenza affidabile dei fatti. Il modello può generare testo grammaticalmente corretto, stilisticamente appropriato e strutturalmente coerente su qualsiasi argomento — inclusi argomenti su cui ha informazioni incomplete o errate. La fluidità del testo non è un indicatore di accuratezza. Questo è il meccanismo sottostante alle allucinazioni: non un guasto, ma il funzionamento corretto di un sistema ottimizzato per la plausibilità, non per la verità.

## Connessioni ad altri topic

Questo topic è il fondamento implicito di tutta la knowledge base. I topic più direttamente collegati sono **Temperature e parametri di generazione** (i parametri che controllano il campionamento token-by-token), **RLHF e Constitutional AI** (le tecniche di allineamento trattate in profondità), **Allucinazioni e verifica dei fatti** (la conseguenza pratica della natura probabilistica del modello) e **Modelli Claude: famiglie e differenze** (come le caratteristiche variano tra versioni della stessa architettura).