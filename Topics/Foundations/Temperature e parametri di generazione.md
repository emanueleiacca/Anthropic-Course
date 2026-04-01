# Temperature e parametri di generazione

Aggiornato: March 31, 2026 10:27 AM
Categoria: Foundations
Corsi: AI Fluency
Stato: Bozza

> 💬 Temperature, top-p e top-k non sono semplici "manopole di creatività": sono parametri che controllano la distribuzione di probabilità sul vocabolario a ogni step di generazione, e calibrarli correttamente è la differenza tra output deterministici e output variabili in modo intenzionale.
> 

## Cos'è e perché importa

Ogni volta che Claude genera un token, calcola una distribuzione di probabilità su tutto il suo vocabolario — decine di migliaia di token possibili. I parametri di campionamento determinano come viene scelto il token successivo da questa distribuzione. Capirli è essenziale non solo per "rendere l'AI più creativa", ma per costruire sistemi affidabili: un'applicazione di estrazione dati strutturati richiede parametri molto diversi da un generatore di narrativa creativa. *(da AI Fluency — AI Fluency)*

## Spiegazione

### Temperature: ampiezza della distribuzione

La temperature scala l'intera distribuzione di probabilità prima del campionamento. Con temperature = 0 (o vicino a zero), il modello sceglie quasi sempre il token con probabilità più alta — il comportamento è quasi deterministico e le risposte tendono a essere coerenti e prevedibili su prompt identici. Con temperature alta (es. 0.9–1.0), la distribuzione viene "allargata": token meno probabili diventano candidati reali, aumentando la varietà e la sorpresa dell'output. *(da AI Fluency — AI Fluency)*

La temperatura non agisce sul "livello di intelligenza" del modello: agisce sulla diversità del campionamento. Abbassarla non rende il modello più preciso — rende il modello più conservativo nello scegliere tra le sue opzioni migliori.

### Top-p (nucleus sampling)

Top-p è un'alternativa alla temperature che opera in modo diverso: invece di scalare la distribuzione, seleziona il sottoinsieme minimo di token la cui probabilità cumulativa raggiunge la soglia p. Con top-p = 0.9, il modello considera solo i token che insieme coprono il 90% della probabilità totale, escludendo le code "lunghe" di token improbabili. Questo limita le scelte a un nucleo più ristretto senza modificare la forma della distribuzione. *(da AI Fluency — AI Fluency)*

In pratica, temperature e top-p possono essere usati insieme, ma Anthropic raccomanda generalmente di variare uno solo dei due per mantenere il comportamento prevedibile.

### Top-k

Top-k limita il campionamento ai k token più probabili, indipendentemente dalla loro distribuzione cumulativa. Con top-k = 5, il modello sceglie sempre tra i 5 token più probabili. È un approccio più rigido di top-p e meno usato nelle applicazioni moderne, ma utile per sistemi dove si vuole controllare in modo assoluto il range di variabilità.

### Calibrazione per caso d'uso

La scelta corretta dei parametri dipende dal tipo di task. Per task di estrazione, classificazione e analisi strutturata dove la risposta giusta è univoca, temperature vicina a 0 è preferibile: si vogliono risposte coerenti e riproducibili. Per brainstorming, generazione creativa, drafting e dialogo naturale, temperature più alta produce output più variegati e utili. *(da AI Fluency — AI Fluency)*

Un anti-pattern documentato dal corso AI Fluency è l'over-reliance sui parametri di default: usare sempre temperature = 1.0 (o qualsiasi default del client) senza adattarla al task specifico porta a risultati sub-ottimali sistematici. Un task di analisi finanziaria con temperature alta produrrà risposte più variabili del necessario; un task creativo con temperature bassa produrrà risposte più rigide e meno interessanti. *(da AI Fluency — AI Fluency)*

### Token counting API

Un aggiornamento recente dell'ecosistema Anthropic è la token counting API, che permette di stimare il numero di token di una richiesta prima di inviarla. Questo ha utilità pratica per la gestione granulare dei rate limit e per stimare i costi prima dell'invio, specialmente in workflow agentici dove il numero di token varia significativamente tra i task. *(da AI Fluency — AI Fluency)*

## Esempi concreti

Per un sistema di estrazione di entità da testi legali, la configurazione ottimale è temperature = 0 (o 0.1 al massimo): si vuole che il modello identifichi sempre le stesse entità nello stesso modo dato lo stesso testo. Per un sistema di generazione di varianti creative di titoli marketing, temperature = 0.8–0.9 produce la varietà desiderata. Mescolare i due casi d'uso con gli stessi parametri produce risultati insoddisfacenti in entrambi. *(da AI Fluency — AI Fluency)*

## Errori comuni e cosa evitare

Un errore comune è confondere temperature alta con "qualità alta". La temperature non migliora le capacità del modello — amplia lo spazio di campionamento. Se il modello non conosce la risposta corretta, alzare la temperature non la farà emergere: produrrà più varianti di risposte sbagliate. Un secondo errore è non documentare i parametri usati in un sistema di produzione: quando il comportamento del sistema cambia (anche per una piccola variazione di temperature), senza documentazione è difficile capire cosa ha causato il cambiamento. *(da AI Fluency — AI Fluency)*

## Connessioni ad altri topic

Questo topic è collegato a **Come funzionano i Large Language Model** (il campionamento è parte del processo di generazione token-by-token), a **Messages API: struttura e parametri** (temperature e top-p sono parametri della chiamata API), e a **Chain-of-thought e ragionamento esplicito** (l'extended thinking ha le sue implicazioni sui parametri di generazione).