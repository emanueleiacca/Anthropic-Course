# Context management nel codice

Aggiornato: April 1, 2026 2:09 PM
Categoria: Claude Code
Corsi: Building with the Claude API, Claude 101, Claude Code in Action, Intro to Subagents
Stato: Completo

> 💬 Decidere quali file includere nel contesto è la variabile operativa più impattante quando si lavora con Claude Code: troppo poco e il modello perde coerenza con il resto del codebase; troppo e si avvicina al limite della context window degradando la qualità.
> 

## Cos'è e perché importa

Nella tab Code di Claude Desktop, il modello opera su file reali del filesystem locale. La scelta di quali file includere nel contesto attivo non è automatica: è una decisione che l'utente o l'agente deve prendere consapevolmente. Sbagliare questa decisione produce risultati insoddisfacenti: codice incoerente con il resto del progetto se il contesto è troppo stretto, o risposte degradate e costose se il contesto è troppo ampio. *(da Claude 101 — Claude 101)*

## Spiegazione

### Il problema della diluizione dell'attenzione

Caricare l'intero codebase nel contesto è un anti-pattern documentato. Quando la context window è piena di informazioni eterogenee — file di configurazione, test, documentazione, sorgenti non correlati al task — il modello tende a perdere di vista i dettagli critici nascosti in mezzo al rumore. Questo fenomeno è chiamato diluizione dell'attenzione: il modello vede tutto il contesto, ma non è in grado di prestare la stessa qualità di attenzione a tutte le parti. *(da Claude 101 — Claude 101)*

### JIT Context Loading: caricare solo ciò che serve, quando serve

Il corso Building with the Claude API introduce il nome preciso per il pattern di caricamento del contesto che Claude Code implementa: JIT (Just-In-Time) context loading. Invece di caricare l'intero repository all'avvio, Claude Code legge solo i file strettamente necessari man mano che avanza nel task. Quando il modello identifica che ha bisogno di capire un modulo specifico, lo legge in quel momento; quando ha bisogno dei test per una funzione, li legge in quel momento. *(da Building with the Claude API — Building with the Claude API)*

La strategia corretta non è "carica tutto" né "carica il minimo", ma "carica esattamente ciò che è rilevante per il task corrente". Il modo operativo consigliato è costruire il contesto incrementalmente: iniziare con i file più rilevanti, osservare come il modello ragiona, e aggiungere file solo se il modello segnala esplicitamente di aver bisogno di informazioni non disponibili.

### Context Compaction nelle sessioni di sviluppo lunghe

Per sessioni che si prolungano nel tempo — refactoring di moduli interi, implementazione di feature complesse che toccano molti file — il JIT loading da solo non è sufficiente: la history della sessione cresce e può raggiungere il limite dei token. La Context Compaction risolve questo problema riassumendo periodicamente i turni più vecchi, preservando le decisioni architetturali già prese e scartando i dettagli intermedi. Le due tecniche sono complementari: la prima ottimizza il caricamento in avanti, la seconda gestisce la crescita della history alle spalle. *(da Building with the Claude API — Building with the Claude API)*

### Soglie di pressione del contesto e comportamenti raccomandati

Il corso Claude Code in Action fornisce soglie operative precise per gestire la finestra di contesto in base al livello di riempimento. Tra 0 e il 50% (Ottimale), Claude opera con massima precisione. Tra il 50 e il 70% (Attenzione), è possibile una perdita di dettagli minori: conviene monitorare le risposte. Tra il 75 e l'85% (Compattazione), è la soglia ideale per invocare `/compact` manualmente o lasciare che il sistema agisca. Oltre il 90% (Critico), il rischio di errori logici è elevato e bisogna usare `/clear` o riavviare la sessione. *(da Claude Code in Action — Claude Code in Action)*

Una tecnica avanzata per preservare informazioni vitali durante la compattazione automatica è aggiungere istruzioni specifiche nel [CLAUDE.md](http://CLAUDE.md), ordinando a Claude di mantenere in memoria certi elementi — come i messaggi di errore dei test in corso o i percorsi dei file in fase di editing.

### Git Worktree isolation come strategia di context management

Il campo `isolation: worktree` in un subagent crea una copia pulita del repository in una directory temporanea. Questo ha due implicazioni per il context management: l'isolamento dello stato del filesystem (le modifiche non contaminano il repository principale fino all'integrazione esplicita) e la pulizia automatica in caso di fallimento (se il task viene interrotto, la worktree viene distrutta, garantendo che il contesto successivo parta sempre da uno stato pulito). *(da Introduction to SubAgents — Intro to Subagents)*

## Esempi concreti

Per un task "Aggiungi il logging a questa funzione di autenticazione", il contesto ottimale include il file `auth.py` con la funzione da modificare, il modulo `logger.py` già usato nel progetto (per seguire le convenzioni esistenti) e il file `test_auth.py` con i test esistenti (per capire i comportamenti attesi). Non include tutti gli altri file del progetto, il README, i file di configurazione CI/CD o i moduli non correlati all'autenticazione. Questo contesto minimale ma sufficiente produce risultati coerenti con il codebase senza degradare l'attenzione del modello. *(da Claude 101 — Claude 101)*

## Errori comuni e cosa evitare

Un errore frequente è interpretare un output di qualità scadente come un problema del modello quando è in realtà un problema di contesto: se Claude produce codice incoerente con il resto del progetto, il primo check deve essere "ho incluso i file che definiscono le convenzioni e le interfacce rilevanti?" spesso la soluzione è aggiungere i file mancanti, non riformulare il prompt. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic è una specializzazione di **Context Window e Token** (gli stessi principi applicati al caso specifico del codice), collegato ad **Agent Skills in Claude Code** (la progressive disclosure come pattern condiviso) e a **Multi-tool use e flussi complessi** (come il contesto si evolve attraverso un flusso multi-step).