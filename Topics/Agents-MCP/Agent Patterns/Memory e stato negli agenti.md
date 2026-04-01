# Memory e stato negli agenti

Aggiornato: April 1, 2026 9:21 AM
Categoria: Agents & MCP
Corsi: Claude 101, Intro to Claude Cowork, Intro to Subagents
Stato: Da Approfondire

> 💬 I modelli linguistici non hanno memoria nativa tra sessioni: ogni chiamata API parte da zero. Gestire lo stato in modo esplicito — in-context, in un external store, o tramite meccanismi come i Progetti — è una scelta architetturale con trade-off precisi.
> 

## Cos'è e perché importa

La mancanza di memoria persistente è una delle differenze fondamentali tra un agente AI e un sistema software tradizionale. Un programma può leggere e scrivere su disco, mantenere variabili in memoria tra le chiamate, accedere a un database. Un modello linguistico, di default, "dimentica" tutto alla fine di ogni sessione. Questo non è un difetto da nascondere, ma un vincolo architetturale da gestire consapevolmente: ogni soluzione ha costi e benefici diversi. *(da Claude 101 — Claude 101)*

## Spiegazione

### Memoria in-context: semplice ma limitata

La strategia più semplice è mantenere la conversazione come array di messaggi e inviarlo completo ad ogni chiamata. Tutto ciò che è nella history è "visibile" al modello e contribuisce al suo ragionamento. Il limite è ovvio: la finestra di contesto è finita, e un array che cresce senza limite raggiunge prima o poi il tetto dei token. Per sessioni brevi e task ben delimitati è la soluzione corretta. *(da Claude 101 — Claude 101)*

### I Progetti come stato implicito

Nell'interfaccia Claude, i Progetti offrono una forma di memoria persistente "di configurazione": i file caricati e le Istruzioni Personalizzate rimangono disponibili tra le sessioni senza dover essere re-inviati. Non è una memoria conversazionale — le conversazioni precedenti non sono visibili nelle nuove — ma è un contesto di dominio stabile. Per molti use case professionali questo è sufficiente: il modello "ricorda" le linee guida, la documentazione e le convenzioni anche in una sessione nuova. *(da Claude 101 — Claude 101)*

### Compounding Context: la memoria che cresce nel tempo

Il corso Intro to Claude Cowork introduce un pattern di gestione della memoria chiamato Compounding Context, che si distingue dagli approcci precedenti per la sua natura deliberatamente incrementale. Non è un external store strutturato né una semplice gestione della history in-context: è un sistema di tre file Markdown curati manualmente dall'utente che Claude legge ad ogni avvio di sessione, accumulando progressivamente più contesto nel tempo. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

I tre file hanno ruoli distinti. Il file `context.md` descrive chi è l'utente, quali sono i suoi obiettivi correnti e la struttura dei progetti attivi — la bussola strategica. Il file `brandvoice.md` definisce lo stile comunicativo: tono, livello di dettaglio, preferenze di formato. Il file `workingstyle.md` specifica le preferenze procedurali: chiedere conferma prima di eliminare file, usare JSON invece di CSV, notificare prima di inviare email esterne. L'efficacia risiede nella persistenza: questi file eliminano la necessità di ri-spiegarsi ad ogni sessione e diventano progressivamente più precisi con il raffinamento nel tempo.

### External store e memory tools

Per sistemi agentici che richiedono memoria persistente vera — ricordare informazioni da sessioni precedenti, accumulare conoscenza nel tempo, tracciare lo stato di task a lungo termine — la soluzione è un external store. I dati rilevanti vengono scritti su un database (vettoriale per ricerca semantica, relazionale per dati strutturati) e recuperati dinamicamente tramite un tool MCP quando pertinenti. Questo trasforma la memoria da un limite della context window a una risorsa potenzialmente illimitata, al costo di aggiungere complessità architetturale e latenza. *(da Claude 101 — Claude 101)*

### query() vs ClaudeSDKClient: stateless e stateful a confronto

Il corso Intro to Subagents chiarisce la distinzione tra i due approcci principali dell'SDK per la gestione della sessione e dello stato. La funzione `query()` è stateless: crea una nuova sessione per ogni chiamata, non mantiene memoria conversazionale tra le invocazioni, e la gestione del ciclo di vita è completamente automatica. È la scelta corretta per script di automazione, task batch, e qualsiasi scenario dove ogni chiamata è indipendente. *(da Introduction to SubAgents — Intro to Subagents)*

Il `ClaudeSDKClient` è stateful: riutilizza la stessa sessione tra più turni, mantiene lo storico della conversazione, e richiede gestione manuale della connessione. È la scelta corretta per interfacce chat interattive, REPL conversazionali, e qualsiasi scenario dove il contesto deve persistere tra i messaggi. Il metodo `reloadPlugins()` permette di ricaricare dinamicamente i subagenti e lo stato dei server MCP senza riavviare l'intera applicazione, risolvendo il problema operativo di dover riavviare la sessione ad ogni modifica di configurazione.

## Esempi concreti

Un agente di code review che lavora su un repository nel tempo può usare un external store per tracciare quali file ha già analizzato, quali pattern di bug ha trovato in passato e le preferenze di stile del team emerse da review precedenti. Ogni nuova sessione recupera dal database le informazioni rilevanti per il task corrente, mantenendo continuità senza dover re-processare tutta la storia. *(da Claude 101 — Claude 101)*

## Errori comuni e cosa evitare

Un errore comune è trattare la context window come se fosse uno store di memoria: aggiungere tutto nella history sperando che il modello ricordi i dettagli importanti. Oltre un certo volume di contesto, il modello inizia a perdere informazioni sepolte nel mezzo — il fenomeno "lost in the middle". Una buona architettura di memoria seleziona attivamente cosa mantenere nel contesto e cosa delegare all'external store. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic è collegato a **Context Window e Token** (i limiti fisici della memoria in-context), a **Progetti e Artifacts** (l'implementazione di memoria di configurazione in Claude), ad **Agentic loop e autonomia** (come lo stato persiste attraverso i turni del loop) e a **Contextual Retrieval ed Enterprise Search** (le tecniche di recupero da external store).