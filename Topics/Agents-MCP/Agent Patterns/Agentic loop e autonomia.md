# Agentic loop e autonomia

Aggiornato: April 1, 2026 9:21 AM
Categoria: Agents & MCP
Corsi: AI Fluency, Building with the Claude API, Claude 101, Claude Code in Action, Intro to Claude Cowork, Intro to MCP, Intro to Subagents
Stato: Da Approfondire

> 💬 L'agentic loop è il ciclo percezione→ragionamento→azione che trasforma Claude da strumento conversazionale a sistema autonomo capace di eseguire task multi-step; il pattern Coordinator-Worker è l'architettura che lo rende scalabile e robusto.
> 

## Cos'è e perché importa

Un agente non è semplicemente un modello che risponde a domande: è un sistema che riceve un obiettivo, pianifica una sequenza di azioni, esegue ciascuna azione usando strumenti disponibili, osserva i risultati e decide il passo successivo fino al completamento. Questo ciclo — percezione, ragionamento, azione — è l'agentic loop. Comprenderne la struttura è essenziale per progettare sistemi che funzionano in modo affidabile, perché ogni step del loop può fallire in modi diversi e richiede strategie di gestione specifiche. *(da Claude 101 — Claude 101)*

## Spiegazione

### La struttura del loop

Il loop agentico si basa sul meccanismo `tool_use` dell'API: quando il modello decide che un'azione è necessaria, invece di rispondere in testo libero restituisce una risposta con `stop_reason == "tool_use"` contenente la specifica del tool da invocare. L'applicazione esegue il tool, invia il risultato al modello come nuovo turno nella conversazione, e il ciclo continua fino a quando il modello ritiene il task completato e risponde con `stop_reason == "end_turn"`.

La corretta gestione del campo `stop_reason` è quindi il meccanismo fondamentale dell'autonomia agentica: ignorarlo o gestirlo in modo errato interrompe il loop prematuramente. *(da Claude 101 — Claude 101)*

### La gerarchia a tre livelli: L1, L2, L3

Il corso Intro to Claude Cowork introduce una formalizzazione precisa dell'agentic loop in tre livelli gerarchici. Il livello L1 è l'Inner Loop, il più atomico: il modello emette una tool call, l'applicazione esegue l'azione e restituisce un risultato, tipicamente uno screenshot o un log. Il livello L2 è il Task Loop, il cuore operativo: comprende la scomposizione dell'obiettivo in step, la pianificazione, l'esecuzione di ogni step e la revisione del piano in base ai risultati. È qui che l'agente può correggere il "task drift" — la deriva rispetto all'obiettivo originale che si accumula nei task lunghi. Il livello L3 è il Meta Loop: gestisce i sub-agenti specializzati, elabora il feedback dell'utente e applica la governance di sicurezza. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

### La formula della probabilità di successo cumulativa

Una delle intuizioni più utili per progettare sistemi agentici affidabili è la modellazione matematica del rischio di degradazione nei task lunghi. La probabilità di successo complessiva di un task a $n$ step può essere approssimata come il prodotto delle probabilità di successo di ogni singolo step:

$P(\text{Successo}) = \prod_{i=1}^{n} P(s_i) \cdot P(v_i)$

Anche se ogni step ha una probabilità di successo del 95%, un task di 20 step ha una probabilità complessiva di circa il 35%. Questo spiega perché l'extended thinking come allocazione di calcolo alla fase di pianificazione pre-azione è cruciale per i task lunghi: ridurre il tasso di errore per step ha un effetto moltiplicativo sulla probabilità di successo totale. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

### Il pattern Coordinator-Worker

Per task complessi, la separazione dei ruoli tra un agente coordinatore e agenti lavoratori specializzati è il pattern architetturale raccomandato da Anthropic. Il coordinatore riceve l'obiettivo dell'utente, mantiene la visione d'insieme e delega i sotto-task agli agenti specialisti, ciascuno con un prompt di sistema estremamente focalizzato su un singolo dominio: scrittura di test, analisi di sicurezza, refactoring, documentazione. *(da Claude 101 — Claude 101)*

Questo approccio offre tre vantaggi concreti. Riduce la "distrazione del modello": un agente con un prompt breve e focalizzato produce risultati più precisi di uno con istruzioni generali. Permette di usare modelli diversi per ruoli diversi — il coordinatore su Sonnet per la pianificazione, i worker su Haiku per task semplici — riducendo il costo complessivo. Migliora la debuggabilità: quando qualcosa va storto, è più facile isolare quale agente ha prodotto l'errore.

### Il pattern Research Lead Agent e le linee guida sul numero di subagenti

Il corso Intro to Subagents formalizza il pattern Research Lead Agent come schema per ricerche complesse. L'agente leader classifica la query in tre tipologie: depth-first (analisi profonda su un singolo argomento), breadth-first (sotto-domande indipendenti eseguibili in parallelo), o straightforward (recupero diretto di una singola risorsa). *(da Introduction to SubAgents — Intro to Subagents)*

Le linee guida sul numero di subagenti seguono una progressione controllata: query semplici richiedono un singolo subagent; query standard 2-3; media complessità 3-5; alta complessità al massimo 5-10, con un limite assoluto di 20. Un vincolo critico: il leader non deve mai delegare la scrittura del report finale a un subagent. La sintesi e il controllo di qualità finale devono rimanere nell'orchestratore principale per garantire coerenza narrativa.

### Context rot: il degrado oltre i 150k token

Il fenomeno del "context rot" è il degrado delle prestazioni che i modelli subiscono quando la finestra di contesto supera le 50.000-150.000 token. Con la crescita del contesto, il modello fatica a mantenere coerenza sulle decisioni precedenti, perde traccia di dettagli critici sepolti nel mezzo, e la qualità complessiva del ragionamento degrada in modo non lineare. *(da Introduction to SubAgents — Intro to Subagents)*

L'architettura dei subagenti è la risposta diretta al context rot: le operazioni intermedie rimangono confinate nel contesto del subagente, mentre l'orchestratore riceve solo il riassunto finale — preservando la qualità del ragionamento strategico.

### Il loop agentico in Claude Code: orientamento, pianificazione, verifica

In Claude Code il loop ha quattro fasi specifiche. Quando viene assegnato un task, l'agente avvia prima una fase di orientamento usando tool di ricerca come `grep` o `ls` per mappare la struttura del repository. Poi formula un piano d'azione che può includere la modifica di più file contemporaneamente. Ogni azione è seguita da una verifica: l'agente esegue i test unitari o i comandi di build per confermare l'assenza di regressioni. Se un test fallisce, l'agente analizza l'output dell'errore e ricomincia il ciclo per correggere la propria implementazione. *(da Claude Code in Action — Claude Code in Action)*

Saltare la fase di orientamento è l'anti-pattern più documentato: produce suggerimenti che violano i pattern esistenti del progetto.

### Script deterministici per compiti ad alto rischio

Per operazioni come migrazioni di database, modifiche a dati di produzione o transazioni finanziarie, un agente che genera ed esegue codice dinamicamente introduce un livello di rischio inaccettabile. L'approccio robusto è scrivere lo script di migrazione in modo deterministico, testarlo, e poi permettere all'agente di invocarlo come tool — non di generarlo. L'agente mantiene il controllo del flusso, ma le operazioni critiche sono eseguite da codice verificato. *(da Building with the Claude API — Building with the Claude API)*

### Anti-pattern del parsing del linguaggio naturale per lo stop del loop

Un anti-pattern pericoloso è tentare di determinare se l'agente ha finito il proprio compito analizzando il testo dell'output, cercando stringhe come "Ho completato il task". Questo approccio è fragile perché dipende dalla coerenza stilistica dell'output del modello, che può variare tra versioni, prompt diversi e anche esecuzioni della stessa richiesta. Il pattern corretto è usare esclusivamente il campo `stop_reason`: `tool_use` significa che il loop deve continuare, `end_turn` significa completamento. *(da Introduction to Model Context Protocol — Intro to MCP)*

Un errore correlato è controllare solo il primo blocco di contenuto nella risposta: nei modelli con extended thinking, il blocco `tool_use` può non essere il primo elemento nell'array `content`. Il codice deve iterare su tutti i blocchi per non perdere tool calls.

### Anti-pattern: Prompt Bloat e mancanza di valutazioni

Il corso AI Fluency identifica due anti-pattern complementari. Il primo è il Prompt Bloat: inserire nel system prompt una quantità eccessiva di istruzioni irrilevanti rispetto al task corrente. Un agente con un system prompt da 50.000 token per un task che ne richiederebbe 2.000 opera con un rapporto segnale-rumore molto basso, degradando attivamente la qualità delle risposte. *(da AI Fluency — AI Fluency)*

Il secondo è la mancanza di valutazioni sistematiche: basare il successo di un sistema agentico su pochi test manuali invece di implementare pipeline di valutazione rigorose. I sistemi agentici possono degradare in modo non ovvio al variare dell'input o al cambio di modello — senza una suite di valutazione automatizzata, questi problemi vengono scoperti in produzione invece che in sviluppo.

### Il fallimento silenzioso: l'anti-pattern più pericoloso

Un worker che fallisce il proprio task può restituire una risposta che sembra valida invece di un errore strutturato. Il coordinatore, non ricevendo un segnale di errore esplicito, continua il workflow con dati incompleti o errati. L'architettura deve prevedere che ogni worker restituisca errori strutturati che permettano al coordinatore di riconoscere il fallimento e tentare una strategia alternativa: retry, approccio diverso, o escalation all'utente. *(da Claude 101 — Claude 101)*

## Esempi concreti

Un workflow tipico di analisi di codice con pattern Coordinator-Worker mostra il loop in azione. Il coordinatore riceve la richiesta di analisi del codebase per problemi di sicurezza e invece di affrontarla monoliticamente delega due task in parallelo: un worker "security-analyzer" con prompt focalizzato su OWASP e vulnerabilità comuni, e un worker "dependency-checker" con prompt focalizzato su CVE nelle dipendenze. Ogni worker opera con contesto ridotto e restituisce un output strutturato in JSON. Il coordinatore raccoglie i due risultati, li consolida e genera il report finale. Questo flusso illustra sia la separazione dei ruoli sia il principio per cui la sintesi finale rimane sempre nell'orchestratore. *(da Claude 101 — Claude 101)*

## Errori comuni e cosa evitare

Oltre al fallimento silenzioso già descritto, un errore comune è non prevedere un limite sul numero di iterazioni del loop. Un agente che fallisce su un task può entrare in un ciclo infinito di tentativi se non c'è un contatore di step con terminazione forzata. Ogni sistema agentico in produzione deve avere un limite esplicito di iterazioni — tipicamente configurabile, es. `max_steps=20` — oltre il quale il sistema si ferma e riporta lo stato all'utente. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic è il centro dell'area Agents & MCP: connette **Gestione errori e retry** (stop_reason come meccanismo del loop), **Model Context Protocol: architettura** (MCP come standard per i tool del loop), **Subagents e task delegation** (il pattern Coordinator-Worker in dettaglio), **Memory e stato negli agenti** (come mantenere lo stato attraverso i turni) e **Evaluation-driven development** (le pipeline di valutazione per sistemi agentici).