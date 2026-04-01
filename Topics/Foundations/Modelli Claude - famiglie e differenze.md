# Modelli Claude: famiglie e differenze

Aggiornato: April 1, 2026 12:33 AM
Categoria: Foundations
Corsi: AI Fluency, Claude 101, Claude Code in Action
Stato: Da Approfondire

> 💬 La famiglia Claude copre uno spettro ampio di modelli — dalla serie 3 alla serie 4, con varianti Haiku, Sonnet e Opus — ciascuna pensata per un diverso punto di equilibrio tra capacità di ragionamento, velocità e costo: scegliere il modello giusto è la prima decisione architetturale di qualsiasi progetto.
> 

## Cos'è e perché importa

Quando si costruisce un'applicazione su Claude, la tentazione è di usare sempre il modello più potente. In realtà, questa scelta ha implicazioni dirette su latenza, costo e qualità del risultato, e spesso il modello "migliore in assoluto" non è quello più adatto al compito specifico. Anthropic ha strutturato la propria offerta in una gerarchia esplicita proprio per guidare questa decisione: non si tratta di una differenza di versione, ma di una differenza di filosofia progettuale. *(da Claude 101 — Claude 101)*

Capire quando usare quale modello è quindi una competenza tecnica a tutti gli effetti, e il corso Claude 101 la tratta come prerequisito implicito a qualsiasi discussione sulle integrazioni avanzate.

## Spiegazione

### Opus: ragionamento profondo per contesti ad alto rischio

Il tier Opus è il modello pensato per task che richiedono la massima capacità di ragionamento e la comprensione di contesti molto lunghi o ambigui. Il suo caso d'uso ideale è dove un errore ha conseguenze significative: analisi legale complessa, ricerca accademica, strategia di business, valutazione di rischio. Non è la scelta ottimale quando la velocità conta, e il suo costo per token riflette fedelmente la sua posizione nella gerarchia. *(da Claude 101 — Claude 101)*

### Sonnet: il punto di riferimento pratico

Il tier Sonnet è attualmente considerato il modello di riferimento per la maggior parte dei task professionali, in particolare per coding e visione. Offre un bilanciamento ideale tra velocità e intelligenza, e il suo prezzo lo rende sostenibile anche per applicazioni con volumi significativi. Per quasi tutti i task di sviluppo software, analisi dati e compiti quotidiani, Sonnet è la scelta di default. *(da Claude 101 — Claude 101)*

### Haiku: latenza e costo per i task ad alto volume

Il tier Haiku è ottimizzato per la velocità e il contenimento dei costi. Nei sistemi che richiedono centinaia o migliaia di chiamate — classificazione dati in tempo reale, moderazione di contenuti, estrazione di strutture da testo grezzo, contestualizzazione di chunk in un pipeline RAG — Haiku permette di costruire pipeline economicamente sostenibili senza sacrificare la qualità sui task semplici. *(da Claude 101 — Claude 101)*

### Claude 3.7 Sonnet: il ragionamento ibrido come discontinuità tecnica

Il lancio di Claude 3.7 Sonnet ha introdotto un'innovazione che merita trattazione separata rispetto alla normale evoluzione della famiglia: il ragionamento ibrido. A differenza dei modelli precedenti che generano testo in modo puramente sequenziale, Claude 3.7 può operare in modalità Extended Thinking, producendo token interni di ragionamento — non visibili nell'output finale, ma accessibili come blocchi di pensiero — che usa per pianificare, ragionare e autocorreggersi prima di fornire la risposta definitiva. Questo rappresenta un cambio architetturale, non solo un miglioramento quantitativo delle performance. *(da AI Fluency — AI Fluency)*

In Standard Mode il modello mantiene la velocità quasi istantanea dei modelli precedenti. In Extended Thinking Mode la latenza aumenta in funzione del budget di token dedicato al ragionamento, ma la qualità su task complessi — matematica, coding, analisi logica — migliora significativamente. Il costo per token rimane identico tra le due modalità, ma i token di pensiero contano verso il limite complessivo.

### Claude 4 e i modelli recenti: Sonnet 4.5 e Opus 4.6

Claude 4 ha introdotto un salto generazionale nelle capacità agentiche, con Sonnet 4.5 e Opus 4.6 come modelli di riferimento per gli scenari di sviluppo avanzato. Entrambi supportano Extended Thinking in modo nativo e sono i modelli predefiniti per Claude Code e Cowork. La modalità `/effort` in Claude Code permette di bilanciare latenza e intelligenza in modo esplicito: alcuni task beneficiano di risposte rapide (refactoring semplice), altri meritano il ragionamento più profondo (debugging di race condition complessi). Usare sempre `/effort` alto indipendentemente dal task aumenta i costi e la latenza senza beneficio proporzionale. *(da Claude Code in Action — Claude Code in Action)*

### Strategia di migrazione tra versioni

Le linee guida ufficiali raccomandano un approccio strutturato quando si aggiorna tra versioni. Le checklist di migrazione prevedono di ricalibrate le istruzioni di sistema e i parametri di temperatura, perché i modelli più recenti ragionano meglio anche senza istruzioni iper-dettagliate. Un fenomeno tipico è che alcune tecniche di "over-prompting" sviluppate per versioni precedenti diventano controproducenti su modelli con capacità di ragionamento più elevate: fornire troppi step espliciti a un modello come Sonnet 3.5 può peggiorare il risultato rispetto a fornire un obiettivo chiaro e lasciare al modello la pianificazione autonoma. *(da Claude 101 — Claude 101)*

Per i dettagli sugli stati del ciclo di vita (Active, Legacy, Deprecated, Retired) e sul changelog strutturato delle deprecazioni, si rimanda al topic dedicato **Gestione del ciclo di vita dei modelli**.

## Esempi concreti

Un caso pratico emblematico è l'architettura multi-agente Coordinator-Worker: il coordinatore, che deve mantenere la visione d'insieme e gestire la complessità dell'orchestrazione, gira su Sonnet, mentre i worker specializzati su task semplici e ripetitivi — estrazione di campi da JSON, classificazione di categoria, contestualizzazione di chunk RAG — girano su Haiku. Il risparmio economico è significativo e la qualità complessiva del sistema non ne risente, perché ogni agente opera nel proprio dominio di competenza. *(da Claude 101 — Claude 101)*

## Errori comuni e cosa evitare

Un errore frequente è trattare la scelta del modello come una decisione una-tantum fissa per tutto il progetto. In realtà, diversi step di uno stesso workflow possono beneficiare di modelli diversi, e la scelta ottimale può cambiare con l'evoluzione della famiglia di modelli. Un secondo errore è assumere che migrare a una versione più recente dello stesso tier non richieda aggiustamenti ai prompt: i miglioramenti nel ragionamento rendono spesso ridondanti alcune istruzioni prescrittive, e mantenerle può produrre output inaspettatamente verbosi o difformi rispetto alle aspettative. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic è strettamente connesso a **Context Window e Token** (la finestra disponibile varia tra modelli), a **Gestione del ciclo di vita dei modelli** (quando e come pianificare le migrazioni), ad **Agentic loop e autonomia** (la scelta del modello per coordinator vs worker nel pattern Coordinator-Worker) e a **Chain-of-thought e ragionamento esplicito** (l'Extended Thinking come estensione nativa del CoT nei modelli recenti).