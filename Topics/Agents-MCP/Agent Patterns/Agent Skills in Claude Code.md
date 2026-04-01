# Agent Skills in Claude Code

Aggiornato: March 31, 2026 8:27 PM
Categoria: Agents & MCP
Corsi: Claude 101, Intro to Agent Skills, Intro to Claude Cowork, Intro to MCP
Stato: Bozza

> 💬 Le Agent Skills sono pacchetti modulari di istruzioni, script e risorse che Claude può caricare dinamicamente: la loro architettura a progressive disclosure è il meccanismo che permette di avere librerie di capacità vastissime senza sovraccaricare il contesto.
> 

## Cos'è e perché importa

Una Skill è la risposta al problema della scalabilità delle capacità operative: come si fa a dotare un agente di decine o centinaia di comportamenti specializzati senza che il system prompt diventi ingestibile? La risposta è la progressive disclosure: invece di caricare tutte le istruzioni nel contesto iniziale, il modello carica solo la Skill pertinente quando ne riconosce il bisogno. Questo mantiene il contesto pulito e focalizzato, indipendentemente da quante Skills sono disponibili. *(da Claude 101 — Claude 101)*

## Spiegazione

### Struttura di una Skill

Una Skill è organizzata come una cartella con una struttura standard e portabile. Il file principale è `SKILL.md`, che contiene i metadati della Skill in formato YAML frontmatter (il `name` in kebab-case e una `description` chiara) e le istruzioni operative. Accanto ad esso, la cartella `scripts/` contiene codice eseguibile (Python o Node.js) che la Skill può invocare, e la cartella `resources/` contiene file di riferimento statici — documentazione, template, dati di grounding. *(da Claude 101 — Claude 101)*

Il formato portabile è intenzionale: una Skill ben costruita può essere usata in diversi ambienti agentici senza modifiche.

### Il meccanismo di progressive disclosure

Quando una libreria di Skills è disponibile, Claude non legge l'intero contenuto di ogni `SKILL.md` all'avvio. Legge solo le descrizioni e, quando identifica un compito per cui una Skill è pertinente, accede dinamicamente ai file di istruzioni o esegue gli script necessari. Questo comportamento ha due conseguenze tecniche importanti. *(da Claude 101 — Claude 101)*

Prima: la descrizione della Skill è il trigger semantico primario. Una buona descrizione segue il pattern "Usa quando..." seguito da una descrizione precisa del contesto di attivazione. Se la descrizione è vaga, la Skill verrà invocata nei momenti sbagliati o non verrà invocata affatto.

Seconda: l'esecuzione degli script non consuma token. Quando Claude esegue uno script Python all'interno di una Skill, solo l'output testuale dello script viene inserito nel contesto conversazionale — il codice dello script stesso non è visibile al modello durante l'elaborazione. Questo permette di incapsulare logica complessa in script deterministici senza sprecare la finestra di contesto. *(da Claude 101 — Claude 101)*

### Scoping e sicurezza Bash

Le Skills possono eseguire comandi Bash, ma questo accesso è limitato tramite namespace specifici. Ad esempio, `Bash(git:*)` permette solo comandi git, `Bash(npm:*)` solo comandi npm. Questo sistema di scoping previene l'esecuzione di comandi arbitrari sul filesystem locale e rende le Skills sicure anche in ambienti condivisi. *(da Claude 101 — Claude 101)*

### Best practice per la qualità

Le linee guida operative per Skills di produzione prevedono: nomi in kebab-case (per evitare collisioni e per supportare l'invocazione tramite slash commands), descrizione con "Usa quando..." esplicita, file `SKILL.md` sotto le 500 righe (per mantenere alta l'attenzione del modello), e scoping Bash limitato al minimo necessario. *(da Claude 101 — Claude 101)*

## Esempi concreti

Una Skill per la validazione di form HTML potrebbe avere questa struttura:

```
skills/
  form-validator/
    SKILL.md          # name: form-validator, description: "Usa quando..."
    scripts/
      validate_form.py  # validazione deterministica
    resources/
      html5_spec.md   # documentazione di riferimento
```

Quando Claude riceve una richiesta di validazione, carica la Skill, esegue lo script Python e riceve solo l'output strutturato nel contesto. *(da Claude 101 — Claude 101)*

## Errori comuni e cosa evitare

Un errore comune nella progettazione di Skills è scrivere descrizioni troppo generiche: "Usa quando lavori con il codice" è un trigger inutile perché quasi ogni compito di sviluppo lo attiverebbe. Una descrizione efficace è specifica sul tipo di task e sul contesto: "Usa quando devi validare form HTML/5 contro le specifiche W3C e verificare l'accessibilità WCAG 2.1." *(da Claude 101 — Claude 101)*

### Skills come vettore di conoscenza procedurale aziendale

Il corso Intro to Claude Cowork amplia la prospettiva sulle Skills aggiungendo una dimensione organizzativa che va oltre il singolo utente: le Skills come strumento per codificare la conoscenza tacita dei dipendenti più esperti e renderla accessibile a tutto il team tramite l'agente. Invece di affidarsi a istruzioni generiche, le aziende sono incoraggiate a "iniettare" i propri manuali operativi reali direttamente nelle Skills Markdown, garantendo che l'agente lavori seguendo i processi interni effettivi. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

Questo trasforma le Skills da strumento individuale a infrastruttura di conoscenza organizzativa: un agente configurato con le Skills aziendali corrette opera seguendo le stesse procedure di un dipendente esperto, senza richiedere che ogni utente conosca le procedure nel dettaglio. Il valore non è solo nell'efficienza individuale, ma nella standardizzazione e nella scalabilità delle pratiche operative. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

### Slash Commands come azioni esplicite e sicure

In Cowork, i Slash Commands (/brief, /reconcile, /research) sono una primitiva distinta dalle Skills: mentre le Skills sono istruzioni di dominio caricate automaticamente per pertinenza, i Slash Commands sono azioni esplicite attivate deliberatamente dall'utente. Questa distinzione è importante per la sicurezza e la prevedibilità: i flussi di lavoro attivati da Slash Commands sono predefiniti e verificati, riducendo la variabilità del comportamento agentico su operazioni critiche o ripetitive. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

### La distinzione definitiva Skills vs Server MCP

Il corso Intro to MCP fornisce la distinzione più chiara e autorevole tra Skills e Server MCP, che vale la pena fissare in modo esplicito. Le **Agent Skills** sono essenzialmente file [SKILL.md](http://SKILL.md) — istruzioni Markdown che guidano il comportamento di Claude Code in contesti specifici. Forniscono conoscenza procedurale, regole di dominio e template di azione. Non hanno capacità infrastrutturali autonome: descrivono come usare cose, non fanno cose da sole. *(da Introduction to Model Context Protocol — Intro to MCP)*

I **Server MCP** forniscono le capacità infrastrutturali effettive: tool eseguibili, risorse leggibili, connessioni a servizi esterni. Non descrivono come fare qualcosa — lo fanno. La combinazione corretta è usare una Skill per istruire Claude su quando e come usare un tool specifico esposto da un server MCP. Per esempio: una Skill descrive la procedura di deploy ("usa il tool `deploy_to_staging` dopo aver eseguito i test, poi attendi la conferma prima di procedere a production"), mentre il server MCP espone effettivamente il tool `deploy_to_staging` che interagisce con l'infrastruttura CI/CD reale. *(da Introduction to Model Context Protocol — Intro to MCP)*

### I tre pattern fondamentali: da Prompt-Only a MCP/Subagents

Il corso Intro to Agent Skills formalizza tre pattern architetturali per la costruzione di Skills, ciascuno con diverso grado di complessità e potere espressivo. La scelta del pattern corretto è una decisione di design che dipende dalla natura del task. *(da Introduction to Agent Skills — Intro to Agent Skills)*

Il **Pattern A (Prompt-Only)** è il punto di ingresso consigliato: il file [SKILL.md](http://SKILL.md) contiene solo istruzioni in linguaggio naturale, senza script o tool esterni. Funziona per revisione del codice, analisi testuale, brainstorming, generazione di testo strutturato. È semplice da creare e da testare, e dovrebbe essere la scelta di default finché non emerge la necessità comprovata di aggiungere complessità.

Il **Pattern B (Skill + Scripts)** aggiunge una cartella `/scripts` con codice eseguibile (Python, Bash, Node.js). Gli script sono ideali per operazioni deterministiche che i modelli linguistici gestiscono con difficoltà: aritmetica complessa, validazione di schemi, manipolazione di file binari, trasformazione di dati strutturati. Il vantaggio critico è che l'esecuzione degli script non consuma token del modello: solo l'output testuale entra nel contesto.

Il **Pattern C (Skill + MCP/Subagents)** è riservato a processi orchestrati che devono interagire con sistemi esterni: database, API di terze parti come Linear o sistemi CI/CD. Questo pattern ha la massima potenza di orchestrazione ma richiede infrastruttura MCP o la configurazione di subagent, e il debugging diventa significativamente più complesso. *(da Introduction to Agent Skills — Intro to Agent Skills)*

### Il principio "insegna a Claude una sola volta"

La filosofia fondante delle Skills è la riduzione della ridondanza: invece di ripetere le stesse istruzioni complesse in ogni conversazione, si cristallizza un workflow in una Skill riutilizzabile che il modello riconosce e invoca autonomamente. Il corso introduce questo come principio "insegna a Claude una sola volta": il costo della progettazione iniziale di una Skill viene ammortizzato su tutti gli usi successivi, ed ogni uso produce risultati più coerenti e prevedibili rispetto alle istruzioni ad hoc. *(da Introduction to Agent Skills — Intro to Agent Skills)*

### Evaluation-Driven Development con il ciclo di test comparativo

La creazione di una Skill non termina con la scrittura del file [SKILL.md](http://SKILL.md). Il processo raccomandato da Anthropic prevede un ciclo di validazione sistematica prima del deployment. Il primo passo è identificare i gap: eseguire i task rappresentativi senza la Skill e documentare dove Claude fallisce o richiede troppi turni. Successivamente si creano almeno tre scenari di test che rappresentano variazioni reali nell'input dell'utente.

Il test avviene tramite esecuzioni parallele: due subagent vengono lanciati contemporaneamente per ogni caso, uno con la Skill e uno come baseline senza. I risultati vengono confrontati su metriche oggettive: successo del task, numero di turni necessari, token totali consumati. Questo garantisce che la Skill aggiunga valore misurabile invece di essere solo un'aggiunta ridondante di istruzioni. *(da Introduction to Agent Skills — Intro to Agent Skills)*

## Connessioni ad altri topic

Questo topic è collegato a **Model Context Protocol: architettura** (le Skills come implementazione ad alto livello delle capacità agentiche), **Context management nel codice** (la progressive disclosure come strategia di gestione del contesto) e **Architettura di Claude Code** (l'ambiente dove le Skills sono native).