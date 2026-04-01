# Claude Agent SDK: integrazione programmatica dei subagenti

Aggiornato: April 1, 2026 9:24 AM
Categoria: API & Tools
Corsi: Claude Code in Action, Intro to Subagents
Stato: Completo

> 💬 Il Claude Agent SDK espone in Python e TypeScript le stesse primitive che alimentano Claude Code, permettendo di integrare la logica dei subagenti in applicazioni personalizzate: query() per automazioni stateless e ClaudeSDKClient per sessioni conversazionali con stato.
> 

## Cos'è e perché importa

Mentre Claude Code offre un'interfaccia interattiva per sviluppatori, molti scenari enterprise richiedono di integrare le capacità agentiche direttamente in applicazioni esistenti: pipeline CI/CD, sistemi di ticketing, backend web, tool interni. Il Claude Agent SDK è la risposta a questa esigenza: espone le stesse primitive che alimentano Claude Code attraverso un'API Python e TypeScript, permettendo di orchestrare subagenti, gestire il ciclo di vita delle sessioni e consumare output strutturati senza dipendere dall'interfaccia CLI. *(da Introduction to SubAgents — Intro to Subagents)*

## Spiegazione

### ClaudeAgentOptions e AgentDefinition: la struttura di configurazione

L'abilitazione dei subagenti nell'SDK richiede due componenti. Il primo è includere lo strumento `Agent` (precedentemente noto come `Task`, rinominato dalla versione 2.1.63) nell'array `allowed_tools` delle opzioni della sessione. Senza questa inclusione, il modello non può delegare task a subagenti anche se la configurazione SDK lo prevede. Il secondo componente è definire i subagenti tramite `AgentDefinition` nella mappa `agents` di `ClaudeAgentOptions`. *(da Introduction to SubAgents — Intro to Subagents)*

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, AgentDefinition

async def main():
    options = ClaudeAgentOptions(
        allowed_tools=["Agent", "Read", "Grep"],  # Agent è obbligatorio
        agents={
            "api-reviewer": AgentDefinition(
                description="Esperto in design di API e documentazione. "
                            "Usa quando devi verificare coerenza degli endpoint "
                            "e chiarezza dei commenti.",
                prompt="Controlla la coerenza degli endpoint e la chiarezza "
                       "dei commenti. Restituisci un report strutturato JSON.",
                tools=["Read", "Grep"],  # Sottoinsieme limitato
                model="sonnet"
            )
        }
    )
    
    async for message in query(
        "Analizza la struttura del modulo auth",
        options=options
    ):
        if hasattr(message, "result"):
            print(f"Risultato: {message.result}")

asyncio.run(main())
```

### query() stateless vs ClaudeSDKClient stateful

La funzione `query()` crea una nuova sessione per ogni chiamata: non c'è memoria conversazionale tra invocazioni diverse, il ciclo di vita della sessione è gestito automaticamente, e l'overhead di setup è azzerato. È la scelta corretta per script di automazione, pipeline batch e qualsiasi scenario dove ogni chiamata è indipendente. *(da Introduction to SubAgents — Intro to Subagents)*

Il `ClaudeSDKClient` mantiene la stessa sessione tra più turni: lo storico della conversazione persiste, la connessione deve essere aperta e chiusa esplicitamente, e il modello può riferirsi a informazioni dei turni precedenti. È la scelta corretta per interfacce chat interattive, REPL conversazionali e qualsiasi scenario dove il contesto deve accumularsi nel tempo.

### Gestione automatica del loop agentico

L'SDK gestisce autonomamente la complessità del loop agentico che richiederebbe implementazione manuale con l'API Messages raw: parsing dei blocchi `tool_use`, routing verso il subagente corretto, raccolta del risultato, reinserimento nel contesto e continuazione del loop fino al `stop_reason == "end_turn"`. Lo sviluppatore riceve solo i messaggi finali di ogni subagente e il risultato conclusivo dell'orchestratore, senza dover gestire la meccanica interna. *(da Introduction to SubAgents — Intro to Subagents)*

L'SDK gestisce anche la compattazione automatica del contesto quando si avvicina ai limiti fisici del modello, equivalente alla Context Compaction trattata nel topic dedicato.

### Output strutturati con JSON Schema

Per garantire che i subagenti restituiscano dati pronti per l'elaborazione programmatica, l'SDK supporta la specifica di JSON Schema per l'output atteso. Il supporto per gli output strutturati è stato rafforzato nelle versioni recenti, con una riduzione degli errori di parsing di circa il 50% nei workflow complessi. Specificare lo schema di output direttamente nel `prompt` del subagente è il modo più diretto: "Restituisci esclusivamente un oggetto JSON con i campi: status (string), issues (array of strings), severity (integer 1-5)." *(da Introduction to SubAgents — Intro to Subagents)*

### Parametri operativi avanzati: permission_mode, cwd e monitoraggio dei costi

Il corso Claude Code in Action documenta parametri aggiuntivi rilevanti per workflow di automazione. Il parametro `permission_mode="acceptEdits"` indica all'agente di accettare automaticamente le modifiche ai file senza richiedere conferma esplicita per ogni operazione di scrittura — utile dove l'overhead delle conferme rallenta l'esecuzione. Il parametro `cwd` specifica la directory di lavoro, equivalente a fare `cd` nel terminale prima di avviare la sessione. *(da Claude Code in Action — Claude Code in Action)*

L'SDK espone il campo `total_cost_usd` nell'oggetto messaggio per il monitoraggio del costo per operazione: utile per sistemi con budget definiti dove si vuole terminare l'agente quando supera una soglia. L'elaborazione in streaming dei messaggi richiede di distinguere il tipo di blocco nell'array `content` — blocchi `text`, `tool_use` e `result` hanno semantiche diverse e non devono essere trattati uniformemente.

### Il vincolo anti-ricorsione

Lo strumento `Agent` non può essere incluso nell'array `tools` di un `AgentDefinition`. I subagenti non possono generare altri subagenti. Questa limitazione è intenzionale per prevenire loop infiniti e costi fuori controllo. L'orchestrazione gerarchica oltre due livelli deve essere gestita a livello di codice applicativo. *(da Introduction to SubAgents — Intro to Subagents)*

## Esempi concreti

Un sistema di code review automatizzato in una pipeline CI/CD mostra la combinazione di due subagenti con modelli diversi per ottimizzare il rapporto qualità-costo:

```python
async def review_pull_request(pr_diff: str) -> dict:
    options = ClaudeAgentOptions(
        allowed_tools=["Agent", "Read"],
        agents={
            "security-scanner": AgentDefinition(
                description="Analizza vulnerabilità di sicurezza nel codice.",
                prompt="Identifica CVE, injection, auth bypass. Output JSON.",
                tools=["Read"],
                model="sonnet"
            ),
            "style-checker": AgentDefinition(
                description="Verifica aderenza alle coding conventions.",
                prompt="Controlla naming, documentazione, complessità. Output JSON.",
                tools=["Read"],
                model="haiku"  # Task più semplice, modello più economico
            )
        }
    )
    
    result = None
    async for msg in query(f"Rivedi questa PR:\n{pr_diff}", options=options):
        if hasattr(msg, "result"):
            result = msg.result
    return result
```

*(da Introduction to SubAgents — Intro to Subagents)*

## Errori comuni e cosa evitare

L'errore più comune è dimenticare di includere `Agent` in `allowed_tools`. Se il tool non è nella lista, il modello non può delegare ai subagenti definiti e cercherà di eseguire tutto da solo — senza segnalare un errore esplicito, semplicemente ignorando la configurazione dei subagenti. *(da Introduction to SubAgents — Intro to Subagents)*

Un secondo errore è usare `ClaudeSDKClient` per script di automazione batch che non richiedono memoria conversazionale. Il client stateful mantiene la connessione aperta tra le chiamate, consumando risorse inutilmente e complicando la gestione degli errori. Per script batch, `query()` è sempre la scelta corretta.

## Connessioni ad altri topic

Questo topic è collegato a **Subagents e task delegation** (la configurazione dei subagenti che l'SDK orchestra), a **Tool Use (Function Calling)** (il meccanismo API sottostante che l'SDK astrae), a **Memory e stato negli agenti** (la distinzione stateless/stateful gestita dall'SDK) e a **Pattern di workflow agentici** (i pattern architetturali implementabili tramite SDK).