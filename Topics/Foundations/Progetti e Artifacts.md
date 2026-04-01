# Progetti e Artifacts

Aggiornato: March 31, 2026 4:11 PM
Categoria: Foundations
Corsi: Claude 101, Intro to Claude Cowork
Stato: Bozza

Fonte: Claude 101 — Claude 101

> 💬 I Progetti e gli Artifacts sono i due meccanismi attraverso cui Claude trasforma l'interazione da effimera a persistente: i Progetti organizzano il contesto di lavoro, gli Artifacts separano il prodotto del lavoro dalla conversazione che lo ha generato.
> 

## Cos'è e perché importa

La modalità conversazionale pura — ogni messaggio indipendente, ogni sessione che riparte da zero — è adeguata per domande semplici ma insufficiente per qualsiasi lavoro professionale serio. I Progetti e gli Artifacts sono la risposta di Anthropic a questo limite: due meccanismi complementari che trasformano Claude da assistente conversazionale a workspace di produttività strutturata. (Fonte: Claude 101)

Comprendere questi due strumenti non è solo imparare due funzionalità dell'interfaccia: è comprendere un cambio di paradigma nel modo di lavorare con i modelli linguistici.

## Spiegazione

### Progetti: workspace persistenti con context steering

Un Progetto è un contenitore di contesto dedicato con una finestra di 200.000 token. All'interno di un Progetto è possibile caricare fino a 20 file di diversi formati (PDF, DOCX, CSV, immagini) che persistono tra le sessioni: non è necessario ricaricarli ad ogni nuova conversazione. Questo trasforma il Progetto in un ambiente di lavoro specializzato con "memoria di dominio" stabile. (Fonte: Claude 101)

Il meccanismo più potente dei Progetti sono le **Istruzioni Personalizzate**: una sezione di system prompt persistente applicata automaticamente a ogni conversazione aperta in quel Progetto. Queste istruzioni fungono da guardrail di contesto: il ruolo del modello, le convenzioni da rispettare, il formato dell'output atteso, le API e le librerie preferite. Un Progetto per lo sviluppo software può includere le linee guida di stile aziendale e la documentazione delle API interne, garantendo coerenza su ogni richiesta senza ripetere il contesto manualmente. (Fonte: Claude 101)

Il valore tecnico risiede nell'eliminazione del "context bleeding": lavorando in Progetti separati per domini diversi (es. un Progetto per lo sviluppo, uno per la comunicazione, uno per la ricerca), si evita che istruzioni e documenti di un dominio influenzino le risposte in un altro.

### Artifacts: il prodotto del lavoro separato dalla conversazione

Gli Artifacts sono una modalità di rendering che separa i contenuti sostanziali generati da Claude — codice, report, visualizzazioni, componenti UI — dalla conversazione che li ha prodotti. Quando Claude genera un componente React, un diagramma Mermaid, un documento Markdown strutturato, questi vengono visualizzati in un pannello laterale dedicato invece di essere incorporati nel flusso della chat. (Fonte: Claude 101)

Dal punto di vista tecnico, gli Artifacts offrono tre capacità distintive. Il **rendering real-time** esegue il codice direttamente nel browser, permettendo di testare componenti web interattivi senza dover copiare il codice in un ambiente esterno. Gli **aggiornamenti mirati** permettono di modificare una sezione specifica del documento senza riscriverlo interamente, preservando la context window e la velocità di risposta. La **persistenza e il forking** consentono di tornare su versioni precedenti di un Artifact e di raffinare il lavoro in modo incrementale, indipendentemente dalla singola risposta del chat. (Fonte: Claude 101)

## Esempi concreti

Un workflow professionale tipico: si crea un Progetto "Analisi Q3" con le istruzioni "Usa sempre grafici matplotlib, output in italiano, formato report con executive summary". Si caricano i file CSV dei dati di vendita. Ogni conversazione produce Artifacts — grafici, tabelle, testi — che vivono nel pannello laterale e possono essere iterati indipendentemente dalla chat. Al termine, gli Artifacts sono il deliverable finale, non la trascrizione della conversazione. (Fonte: Claude 101)

## Errori comuni e cosa evitare

Un errore comune con i Progetti è caricare file irrilevanti pensando che "più contesto è meglio": 20 file non correlati al task corrente riempiono la context window con rumore che degrada la qualità delle risposte. La regola è caricare solo ciò che è strettamente pertinente al dominio del Progetto. Con gli Artifacts, un errore tipico è trattarli come output da copiare altrove: il pannello Artifact è un ambiente di lavoro interattivo, non un pannello di preview. Iterare direttamente sull'Artifact è spesso più efficiente che tornare alla chat per ogni modifica. (Fonte: Claude 101)

### Compounding Context: i file di contesto come memoria di configurazione persistente

Il corso Intro to Claude Cowork introduce un pattern specifico di persistenza chiamato Compounding Context: invece di riconfigurare il contesto ad ogni sessione, l'utente crea una serie di file Markdown che Claude legge ad ogni avvio. Questi file non sono equivalenti agli Artifacts (che sono output del lavoro) né alle Istruzioni Personalizzate dei Progetti (che sono system prompt): sono documenti di contesto personalizzati che crescono e si raffinano nel tempo, diventando progressivamente più utili quanto più vengono curati. (Fonte: Intro to Claude Cowork)

Il pattern ha tre componenti standard: `context.md` (chi è l'utente, obiettivi correnti, struttura dei progetti attivi), `brandvoice.md` (stile comunicativo preferito, livello di dettaglio, tono) e `workingstyle.md` (preferenze procedurali: chiedere conferma prima di cancellare, usare JSON invece di CSV, ecc.). La persistenza di questi file trasforma progressivamente l'agente da strumento generico a collaboratore che conosce il contesto specifico dell'utente. (Fonte: Intro to Claude Cowork)

## Connessioni ad altri topic

Questo topic è strettamente connesso a **System prompt e separazione dei ruoli** (le Istruzioni Personalizzate come implementazione ad alto livello del system prompt), a **Context Window e Token** (la finestra da 200k token e i limiti di file), a **Memory e stato negli agenti** (i Progetti come forma di memoria persistente di configurazione) e a **Prompt Caching** (l'ottimizzazione del costo per Progetti con file grandi e statici).