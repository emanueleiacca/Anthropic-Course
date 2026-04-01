# Multi-tool use e flussi complessi

Aggiornato: April 1, 2026 2:10 PM
Categoria: Claude Code
Corsi: Claude 101, Intro to Claude Cowork
Stato: Completo

> 💬 La tab Cowork di Claude Desktop trasforma task complessi e multi-step — che coinvolgono shell, editor, browser e API in sequenza — in operazioni asincrone eseguite in una VM isolata, senza bloccare il flusso di lavoro dell'utente.
> 

## Cos'è e perché importa

I flussi di lavoro reali raramente si riducono a una singola operazione: analizzare un dataset richiede di leggere file, eseguire codice, interpretare risultati e produrre un report. Costruire un feature richiede di modificare più file, eseguire test, verificare che l'applicazione si avvii correttamente. La tab Cowork di Claude Desktop è progettata per orchestrare questi flussi complessi in modo autonomo, all'interno di un ambiente sicuro e isolato. *(da Claude 101 — Claude 101)*

## Spiegazione

### L'architettura VM di Cowork

Cowork opera in una macchina virtuale isolata, separata dal sistema operativo dell'utente. Questa scelta architetturale ha conseguenze importanti: le azioni dell'agente avvengono in un ambiente controllato dove l'accesso alla rete e al filesystem è gestito attraverso policy esplicite. L'agente può installare pacchetti, eseguire script, avviare server — tutto all'interno della VM, senza rischio di effetti indesiderati sul sistema operativo host. *(da Claude 101 — Claude 101)*

### Orchestrazione di tool in sequenza

Il punto di forza di Cowork è la capacità di usare strumenti diversi in sequenza all'interno di un unico flusso: leggere file dal filesystem della VM, eseguire codice Python nel terminale, consultare documentazione web, produrre file di output. Ogni step è un'azione distinta che il modello pianifica e poi esegue, osservando il risultato prima di decidere il passo successivo. *(da Claude 101 — Claude 101)*

Un esempio concreto dal corso: "Analizza questi 10 log di errore, identifica i pattern ricorrenti, e crea un report Excel con grafici che mostri la distribuzione per tipo di errore e per ora del giorno." Questo richiede parsing di testo, analisi statistica, generazione di visualizzazioni e produzione di un file Excel — tutto orchestrato autonomamente da Cowork senza intervento dell'utente.

### Cowork come processo persistente

A differenza della tab Code che è una sessione interattiva, Cowork è un processo che continua in background anche se l'applicazione viene chiusa. Questo lo rende adatto per task che richiedono ore: l'utente assegna il compito e torna quando è terminato. La funzionalità Dispatch estende ulteriormente questa caratteristica: è possibile inviare task a Cowork tramite dispositivo mobile e ritrovare il lavoro completato al ritorno al desktop. *(da Claude 101 — Claude 101)*

## Esempi concreti

Un workflow di data analysis tipico in Cowork: l'utente carica nella VM 10 file CSV di dati di vendita e chiede un report comparativo mensile. Cowork legge i file, esegue un'analisi Python per calcolare le metriche richieste, genera grafici con matplotlib, e produce un report Word o Excel strutturato — tutto in sequenza, in background, restituendo il file completato al termine. *(da Claude 101 — Claude 101)*

### Computer Use come estensione del flusso multi-tool

Cowork può estendere il proprio repertorio di tool al di là di file e API, includendo qualsiasi applicazione grafica visibile sullo schermo tramite Computer Use: l'agente riceve screenshot come percezione e invia comandi di mouse e tastiera come azione. Questo permette di includere in un flusso multi-step anche applicazioni legacy senza API, interfacce web non strutturate e software desktop. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

Per la trattazione tecnica dettagliata del meccanismo di Computer Use — loop di validazione visiva, algoritmo di scaling delle coordinate, limiti di affidabilità rispetto alle integrazioni strutturate — si rimanda al topic dedicato **Computer Use e visione computerizzata**.

## Errori comuni e cosa evitare

Un errore comune è sottovalutare la rilevanza dell'isolamento VM: Cowork non ha accesso diretto al filesystem locale dell'utente (al di fuori dei file esplicitamente condivisi con la VM). Chi si aspetta che Cowork "veda" automaticamente i file sul desktop locale resterà deluso. Il flusso corretto è caricare esplicitamente i file nella VM o condividere una cartella specifica. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic si raccorda con **Architettura di Claude Code** (l'ecosistema delle tre tab), con **Agentic loop e autonomia** (il loop agentico in un ambiente VM) e con **Agent Skills in Claude Code** (le Skills come capacità modulari che Cowork può invocare).