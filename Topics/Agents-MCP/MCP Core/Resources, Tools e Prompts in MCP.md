# Resources, Tools e Prompts in MCP

Aggiornato: April 1, 2026 9:32 AM
Categoria: Agents & MCP
Corsi: Claude 101, Intro to MCP
Stato: Completo

> 💬 Le tre primitive MCP — Resources, Tools e Prompts — non sono varianti dello stesso concetto: ciascuna ha un ruolo architetturale preciso e ben distinto che determina quando e come usarla nella progettazione di un server.
> 

## Cos'è e perché importa

Quando si progetta un server MCP, la prima decisione è quali primitive esporre. La scelta non è arbitraria: Resources, Tools e Prompts modellano tre modi fondamentalmente diversi in cui un server può arricchire il contesto del modello. Confonderli porta a server difficili da usare o che non si comportano come previsto. *(da Claude 101 — Claude 101)*

## Spiegazione

### Chi controlla cosa: model-controlled, application-controlled, user-controlled

Il corso Intro to MCP introduce una distinzione concettuale che chiarisce il ruolo di ciascuna primitiva in modo preciso. I Tools sono "model-controlled": è il modello a decidere autonomamente se, quando e con quali argomenti invocare uno strumento, basandosi sulla descrizione e sul contesto della conversazione. Le Resources sono "application-controlled": è l'applicazione client o l'utente a determinare quali risorse caricare nel contesto, non il modello in modo autonomo. I Prompts sono "user-controlled": è tipicamente l'utente o l'applicazione a selezionare un template per avviare una determinata attività. *(da Introduction to Model Context Protocol — Intro to MCP)*

Questa distinzione ha implicazioni importanti per la sicurezza: le azioni con effetti collaterali (scrittura, invio, modifica) devono essere esposte come Tools — dove il modello prende la decisione di invocarle e l'utente può essere avvisato — non come Resources, che sono passive.

### Resources: dati in sola lettura

Le Resources sono sorgenti di dati accessibili al modello in modalità lettura. Una Resource è identificata da un URI e può rappresentare un file, una pagina di documentazione, il risultato di una query, lo stato corrente di un sistema. Il modello può richiedere il contenuto di una Resource e includerlo nel proprio contesto, ma non può modificarla tramite questo meccanismo. *(da Claude 101 — Claude 101)*

Il caso d'uso tipico è un server di documentazione che espone ciascun documento come Resource. Il modello può leggerli dinamicamente invece di averli tutti pre-caricati nel contesto, permettendo librerie molto più ampie senza degradare le performance.

### Tools: azioni eseguibili

I Tools sono funzioni che il modello può invocare per eseguire azioni con effetti nel mondo reale: scrivere su un database, chiamare un'API esterna, eseguire codice, inviare notifiche. A differenza delle Resources, i Tools modificano lo stato del sistema. Ogni Tool ha uno schema JSON che descrive i parametri accettati, e il modello usa questo schema per costruire le chiamate corrette. La distinzione con le Resources è netta: una Resource legge lo stato, un Tool lo modifica. *(da Claude 101 — Claude 101)*

### Prompts: template pre-definiti e workflow riutilizzabili

I Prompts sono template di prompt che il server mette a disposizione del client. Invece di lasciare che il modello costruisca da zero il prompt per un'operazione complessa, il server fornisce template ottimizzati per i propri use case. Sono particolarmente utili per operazioni che richiedono un formato di input molto specifico o che beneficiano di istruzioni elaborate già testate. *(da Claude 101 — Claude 101)*

Il corso approfondisce il ruolo dei Prompts come meccanismo per garantire coerenza nelle prestazioni del modello su operazioni standardizzate. Un Prompt MCP non è solo un template di testo: può definire stili di risposta specifici, passaggi di analisi complessi o strutture di output rigide. Per organizzazioni che usano MCP in ambienti enterprise, i Prompts possono codificare workflow approvati — come il processo di approvazione di una modifica al database o il formato standard di un report di audit — garantendo che il modello li segua in modo consistente. *(da Introduction to Model Context Protocol — Intro to MCP)*

## Esempi concreti

Un server MCP per un sistema di ticketing illustra l'uso combinato delle tre primitive. Le Resources espongono i dati in sola lettura: la lista dei ticket aperti, i dettagli di un ticket specifico, la documentazione dei codici di errore. I Tools espongono le azioni con effetti: `create_ticket`, `update_ticket_status`, `assign_ticket`, `add_comment`. I Prompts forniscono il template per la creazione di ticket di bug con tutti i campi richiesti pre-strutturati — garantendo che il modello generi ticket conformi agli standard del team senza improvvisare il formato ogni volta. *(da Claude 101 — Claude 101)*

## Errori comuni e cosa evitare

Un errore di design frequente è esporre come Tool operazioni che dovrebbero essere Resources — ad esempio, un tool `get_documentation(section)` invece di una Resource `docs://section`. La distinzione è che le Resources sono passive (il modello decide quando leggerle) mentre i Tools sono attivi (il modello decide quando eseguirli, con latenza e potenziali effetti collaterali). Se l'operazione non ha effetti collaterali e non è computazionalmente costosa, probabilmente è meglio esporla come Resource. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic è la continuazione diretta di **Model Context Protocol: architettura** (il framework generale) e prerequisito per **Build di server MCP in Python** (l'implementazione concreta delle tre primitive) e **Sampling e notifiche MCP** (funzionalità avanzate che si basano su queste primitive).