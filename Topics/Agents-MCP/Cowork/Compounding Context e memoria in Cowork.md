# Compounding Context e memoria persistente in Cowork

Aggiornato: April 1, 2026 2:06 PM
Categoria: Agents & MCP
Corsi: Intro to Agent Skills, Intro to Claude Cowork
Stato: Completo

Fonte: Introduction to Claude Cowork — Intro to Claude Cowork

> 💬 Il Compounding Context è il pattern di memoria persistente specifico di Cowork: tre file Markdown — [context.md](http://context.md), [brandvoice.md](http://brandvoice.md), [workingstyle.md](http://workingstyle.md) — letti automaticamente ad ogni sessione, che crescono nel tempo e trasformano progressivamente l'agente da strumento generico a collaboratore che conosce il contesto dell'utente.
> 

## Cos'è e perché importa

Uno dei limiti più frustranti nell'uso quotidiano di un agente AI è dover ri-spiegare il contesto ad ogni sessione: chi sei, su cosa stai lavorando, come preferisci ricevere le risposte, quali sono le regole operative della tua organizzazione. Ogni sessione parte da zero, e l'agente non ha memoria di ciò che è stato detto prima. Il Compounding Context è la risposta di Cowork a questo problema: invece di affidarsi alla memoria del modello (che non esiste tra sessioni) o a un external store strutturato (che richiede infrastruttura), si usa un sistema semplice di file di testo che l'agente legge automaticamente all'avvio. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

L'aggettivo "compounding" è intenzionale: il valore di questi file cresce nel tempo. Ogni raffinamento li rende più precisi, e la precisione crescente riduce gli errori di interpretazione, il numero di correzioni necessarie, e il tempo speso a ri-allineare l'agente sulle aspettative. L'investimento iniziale nella loro creazione ripaga esponenzialmente sull'uso continuativo.

## Spiegazione

### [context.md](http://context.md): la bussola strategica

Il file `context.md` è il documento più importante del sistema: descrive chi è l'utente, quali sono i suoi obiettivi correnti e la struttura dei progetti attivi. Non è un curriculum né una biografia: è il briefing che un nuovo collaboratore riceverebbe il primo giorno — abbastanza contesto da poter prendere decisioni pertinenti senza richiedere chiarimenti su ogni piccola cosa. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

Un `context.md` efficace risponde a domande come: qual è il ruolo professionale dell'utente? Su quali progetti è attualmente concentrato? Quali sono le scadenze rilevanti? Chi sono i principali stakeholder con cui interagisce? Quali strumenti e sistemi usa quotidianamente? Questo file va aggiornato quando cambiano i progetti o le priorità — non è un documento statico ma una mappa del lavoro corrente.

### [brandvoice.md](http://brandvoice.md): lo stile come istruzione permanente

Il file `brandvoice.md` definisce lo stile comunicativo che l'agente deve adottare in tutti gli output. La sua funzione è equivalente a quella di un system prompt persistente dedicato al tono, ma formulata in termini operativi e aggiornabile senza conoscere le API. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

Il file può specificare: il livello di formalità desiderato (formale per comunicazioni esterne, informale per note interne), la preferenza per risposte brevi e dirette o per analisi articolate, il formato preferito degli output (tabelle, elenchi, prosa), la lingua e le convenzioni tipografiche, e gli esempi di testi esistenti da usare come riferimento stilistico. Un `brandvoice.md` ben curato elimina la necessità di specificare il formato ad ogni prompt.

### [workingstyle.md](http://workingstyle.md): le preferenze procedurali

Il file `workingstyle.md` specifica le preferenze operative: come l'agente deve comportarsi sui punti di decisione, sulle azioni potenzialmente rischiose e sul formato degli output di dati. Questo è il file dove si codificano le regole di sicurezza personali: "chiedi sempre conferma prima di eliminare file", "non inviare mai email senza mostrami la bozza", "usa sempre JSON invece di CSV per gli output di dati", "se non sei sicuro dell'interpretazione, chiedi invece di procedere". *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

Queste regole sarebbero difficili da inserire in ogni singolo prompt, ma inserite nel `workingstyle.md` diventano comportamenti predefiniti dell'agente per tutta la durata dell'uso. Il file può anche specificare preferenze positive: "struttura sempre le analisi con executive summary in testa", "per i task di ricerca, cita sempre le fonti", "quando crei file, usa sempre la naming convention [data]-[tipo]-[descrizione]".

### Tabella comparativa: [CLAUDE.md](http://CLAUDE.md), Skills, Auto Memory e Compounding Context

Il corso Intro to Agent Skills fornisce la mappa definitiva per orientarsi tra i diversi meccanismi di memoria e istruzioni persistenti nell'ecosistema Claude Code. Il [CLAUDE.md](http://CLAUDE.md) viene caricato all'avvio della sessione ed è sempre presente nel contesto: è il meccanismo corretto per regole globali di progetto come standard di linting, comandi di build, architettura. Il suo impatto sul contesto è permanente e proporzionale alla sua lunghezza. *(da Introduction to Agent Skills — Intro to Agent Skills)*

Le Agent Skills vengono caricate al matching della descrizione, on-demand: hanno costo zero nella finestra di contesto finché il task non le richiede. Sono il meccanismo corretto per workflow specialistici e guide operative che non devono essere sempre presenti. L'Auto Memory viene gestita autonomamente da Claude, che scrive note basandosi sulle correzioni dell'utente durante le sessioni: zero configurazione manuale, ma zero controllo esplicito sul contenuto.

I file di Compounding Context di Cowork si posizionano come via di mezzo: vengono caricati all'avvio come [CLAUDE.md](http://CLAUDE.md), ma sono curati manualmente dall'utente e crescono nel tempo come l'Auto Memory. Sono più specifici del [CLAUDE.md](http://CLAUDE.md) (descrivono l'utente, non il progetto) e più controllabili dell'Auto Memory (il contenuto è esplicito e modificabile).

### Il meccanismo di caricamento automatico

I tre file vengono letti da Claude all'avvio di ogni sessione di Cowork, prima che l'utente inserisca qualsiasi prompt. Questo significa che il loro contenuto è sempre presente nel contesto come fondamento su cui si costruisce ogni interazione. Il costo in token è proporzionale alla lunghezza dei file: file concisi e ben strutturati sono preferibili a documenti lunghi e ridondanti, sia per minimizzare il token overhead sia per mantenere alta la qualità dell'attenzione del modello sui contenuti rilevanti. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

### Differenza rispetto ad altri pattern di memoria

Il Compounding Context si posiziona in modo distinto rispetto agli altri pattern di memoria trattati nella knowledge base. A differenza della memoria in-context (la history della conversazione corrente), persiste tra sessioni diverse. A differenza di un external store strutturato con RAG, non richiede infrastruttura e non ha latenza di recupero. A differenza delle Istruzioni Personalizzate dei Progetti in [Claude.ai](http://Claude.ai) (che sono system prompt fissi), i file di Compounding Context sono documenti editabili dall'utente che evolvono nel tempo con un processo di raffinamento esplicito. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

## Esempi concreti

Un consulente che usa Cowork per la gestione di un portafoglio clienti potrebbe avere un `context.md` che elenca i cinque clienti attivi con le rispettive scadenze e priorità, un `brandvoice.md` che specifica tono formale per le comunicazioni esterne e analitico per le note interne, e un `workingstyle.md` che impone di chiedere conferma prima di inviare qualsiasi comunicazione a clienti e di usare sempre il template aziendale per i report. Dopo tre mesi di uso quotidiano, questi file hanno accumulato un livello di precisione che riduce al minimo la necessità di correzioni e ri-spiegazioni. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

## Errori comuni e cosa evitare

Un errore comune è scrivere i file di contesto una volta e non aggiornarli mai. Il valore del Compounding Context dipende dalla sua accuratezza: un `context.md` che descrive progetti conclusi mesi fa introduce rumore invece che segnale, portando l'agente a fare riferimento a contesto irrilevante. Una buona pratica è aggiornare il `context.md` ogni volta che cambiano i progetti principali, e rivedere `workingstyle.md` dopo ogni sessione in cui l'agente ha prodotto comportamenti indesiderati che avrebbero potuto essere prevenuti con una regola esplicita. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

Un secondo errore è rendere i file eccessivamente lunghi cercando di coprire ogni eventualità. File molto lunghi consumano molti token e aumentano il rischio che dettagli importanti vengano trascurati nel mezzo del documento. La regola empirica è che ogni file dovrebbe coprire solo ciò che è davvero permanente e trasversale a tutti i task, non le istruzioni specifiche per singole operazioni (quelle appartengono ai prompt o alle Skills del Plugin).

## Connessioni ad altri topic

Questo topic è la specializzazione di Cowork di **Memory e stato negli agenti** (il pattern di memoria persistente leggero), complementare a **Plugin di Cowork: architettura e personalizzazione** (i Plugin per le capacità operative, il Compounding Context per la personalizzazione dell'identità), e collegato a **System prompt e separazione dei ruoli** (i file di contesto come implementazione distribuita del system prompt persistente) e a **Context Window e Token** (il token overhead dei file di contesto caricati ad ogni sessione).