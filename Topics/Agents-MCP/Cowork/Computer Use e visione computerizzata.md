# Computer Use e visione computerizzata

Aggiornato: March 31, 2026 2:35 PM
Categoria: Agents & MCP
Corsi: Intro to Claude Cowork
Stato: Completo

Fonte: Introduction to Claude Cowork — Intro to Claude Cowork

> 💬 Computer Use è la capacità di Claude di interagire con qualsiasi ambiente desktop tradizionale attraverso screenshot come percezione e comandi di mouse e tastiera come azione: trasforma l'agente da sistema che opera su API e file strutturati a sistema capace di usare qualsiasi applicazione grafica.
> 

## Cos'è e perché importa

La maggior parte degli strumenti agentici opera su interfacce strutturate: API con endpoint definiti, file in formati standard, database con schemi precisi. Questo copre molti casi d'uso, ma lascia fuori un'enorme porzione del lavoro reale: applicazioni desktop senza API pubblica, interfacce web che non espongono dati in modo strutturato, software legacy che esiste solo come applicazione grafica. Computer Use risolve questo problema in modo radicale: invece di richiedere un'interfaccia strutturata, l'agente interagisce con l'ambiente esattamente come farebbe un essere umano — guardando lo schermo e controllando mouse e tastiera. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

Questo cambio di paradigma ha implicazioni profonde: qualsiasi applicazione visibile su uno schermo diventa potenzialmente automatizzabile, indipendentemente dal fatto che esponga un'API. Il costo è una maggiore complessità tecnica e una minorà affidabilità rispetto alle integrazioni strutturate.

## Spiegazione

### L'architettura di mediazione: X11 e sandbox virtualizzata

Computer Use non avviene tramite accesso diretto al sistema operativo dell'utente. L'agente opera attraverso un'interfaccia di mediazione — tipicamente un server X11 su Linux o una sandbox virtualizzata — che si interpone tra Claude e il display reale. In questo ambiente mediato, Claude riceve screenshot dell'area di lavoro corrente come input visivo, elabora l'immagine per identificare gli elementi UI rilevanti, e invia comandi di mouse (click, drag, scroll) e tastiera (testo, shortcut) che il sistema di mediazione traduce in azioni reali. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

Questa architettura offre un importante vantaggio di sicurezza: le azioni dell'agente avvengono in un ambiente controllato, e il livello di accesso può essere limitato senza modificare il meccanismo fondamentale di percezione-azione.

### Il loop di validazione visiva

Ogni azione nel Computer Use è seguita da una verifica: dopo ogni click, ogni inserimento di testo, ogni navigazione, l'agente cattura un nuovo screenshot e analizza se l'azione ha prodotto il risultato atteso. Questo loop di validazione visiva costante è il meccanismo che garantisce la correttezza delle azioni, particolarmente importante in interfacce dove il feedback visivo è l'unico segnale disponibile. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

Il loop si inserisce naturalmente nella struttura L1 dell'agentic loop: ogni tool call di tipo `left_click` o `type_text` è seguita dalla restituzione di uno screenshot come risultato, che l'agente analizza prima di emettere la prossima tool call. L'intero flusso è quindi: percepire (screenshot) → ragionare (identificare azione necessaria) → agire (comando mouse/tastiera) → percepire di nuovo (nuovo screenshot) → ripetere.

### L'algoritmo di scaling delle coordinate

Una sfida tecnica specifica di Computer Use è la mappatura delle coordinate tra il sistema di riferimento di Claude e quello del display reale. Le immagini catturate vengono ridimensionate per rientrare nei limiti della finestra di contesto (circa 1.15 megapixel totali), il che significa che le coordinate identificate da Claude nell'immagine compressa non corrispondono direttamente alle coordinate reali del display. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

Il fattore di scala $s$ si calcola come:

$s = \min\left(1.0,\ \frac{1568}{\max(W, H)},\ \sqrt{\frac{1{,}150{,}000}{W \times H}}\right)$

dove $W$ e $H$ sono la larghezza e l'altezza reali del display. I comandi di click devono quindi essere ricalcolati programmaticamente prima di essere inviati al sistema:

```python
def scale_to_screen(claude_x, claude_y, scale_factor):
    screen_x = claude_x / scale_factor
    screen_y = claude_y / scale_factor
    return screen_x, screen_y
```

Questa precisione è particolarmente critica per elementi UI piccoli: un menu a tendina, una checkbox o un link in una tabella occupano pochi pixel, e un errore di pochi pixel nella posizione del click porta al fallimento dell'azione senza alcun messaggio di errore esplicito. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

### Ragionamento spaziale e riconoscimento UI

Oltre alla precisione delle coordinate, Computer Use richiede che il modello sia capace di ragionamento spaziale: identificare la posizione di elementi UI all'interno di un layout visivo complesso, comprendere gerarchie di menu, riconoscere stati di elementi (abilitato/disabilitato, selezionato/deselezionato), e navigare interfacce senza documentazione strutturata. I modelli Claude Sonnet 4.5 e Opus 4.6 sono stati ottimizzati per questo tipo di ragionamento visivo. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

## Esempi concreti

Un caso d'uso emblematico è l'estrazione di dati da ricevute fotografate o da PDF di fatture: l'agente apre il file, identifica visivamente i campi rilevanti (data, importo, fornitore, codice IVA), estrae i valori e li inserisce in un foglio Excel con formule già configurate. Questo flusso non richiederebbe nulla di strutturato: funziona su qualsiasi formato visivo di ricevuta, inclusi quelli scansionati o fotografati con la fotocamera. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

Un secondo caso tipico è la navigazione di software legacy senza API: inserimento di dati in form di applicazioni enterprise che non espongono endpoint, export di report da sistemi ERP datati, o automazione di workflow in applicazioni desktop che non supportano scripting.

## Errori comuni e cosa evitare

L'errore più comune è assumere che Computer Use sia affidabile quanto un'integrazione API strutturata. La variabilità nei layout delle interfacce grafiche, i cambiamenti di tema o risoluzione, le animazioni e i ritardi di caricamento delle UI sono tutte fonti di fallimento che non esistono nelle integrazioni strutturate. La strategia corretta è usare Computer Use come ultima risorsa — quando non esiste un'API o un connettore MCP — e costruire sempre una logica di verifica e retry intorno alle azioni visive. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

Un secondo errore è non gestire i timeout di caricamento: un'applicazione che richiede 3 secondi per caricare una pagina può portare l'agente a cliccare su elementi non ancora presenti nel DOM, producendo fallimenti silenziosi difficili da diagnosticare.

## Connessioni ad altri topic

Questo topic è una specializzazione di **Multi-tool use e flussi complessi** (il loop visivo come forma specifica di orchestrazione multi-step), collegato a **Agentic loop e autonomia** (il loop L1 come meccanismo di validazione visiva), a **Sicurezza nei sistemi agentici** (l'architettura di sandboxing che isola le azioni dell'agente), e a **Architettura di Claude Code** (Cowork come ambiente operativo costruito su questo meccanismo).