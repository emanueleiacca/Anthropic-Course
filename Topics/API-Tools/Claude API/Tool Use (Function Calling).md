# Tool Use (Function Calling)

Aggiornato: April 1, 2026 9:14 AM
Categoria: API & Tools
Corsi: Building with the Claude API
Stato: Completo

> 💬 Il Tool Use trasforma Claude da sistema isolato a orchestratore di servizi: il modello non esegue direttamente le azioni, ma emette richieste strutturate che l'applicazione client soddisfa, creando un ciclo a quattro fasi che è il fondamento di qualsiasi sistema agentico reale.
> 

## Cos'è e perché importa

Un modello linguistico che può solo generare testo è uno strumento potente ma incompleto. Le applicazioni reali richiedono di leggere database, chiamare API esterne, aggiornare record, inviare notifiche — azioni che il modello non può compiere direttamente perché non ha accesso al mondo esterno. Il Tool Use risolve questo problema attraverso un contratto preciso: lo sviluppatore definisce le azioni disponibili come strumenti con schemi JSON, Claude decide quando e come usarli, e l'applicazione client esegue l'azione reale e riporta il risultato. Questa separazione tra decisione e esecuzione è ciò che rende il sistema sicuro, prevedibile e controllabile. *(da Building with the Claude API — Building with the Claude API)*

## Spiegazione

### Il ciclo a quattro fasi

L'implementazione del Tool Use segue un protocollo rigido a quattro fasi che deve essere rispettato integralmente perché il sistema funzioni correttamente. *(da Building with the Claude API — Building with the Claude API)*

Nella prima fase, la definizione, lo sviluppatore fornisce a Claude nella chiamata API una lista di strumenti con nomi descrittivi, descrizioni dettagliate in linguaggio naturale e schemi JSON che specificano i parametri accettati. Questa lista viene passata nel campo `tools` della richiesta e costituisce il "menu di azioni" da cui Claude può scegliere.

Nella seconda fase, l'invocazione, Claude decide che uno strumento è necessario per completare il task e interrompe la generazione con `stop_reason: "tool_use"`, restituendo un blocco strutturato con il nome del tool e gli argomenti necessari. Il modello non esegue nulla — dichiara soltanto l'intenzione di eseguire.

Nella terza fase, l'esecuzione client, l'applicazione riceve la richiesta di tool use ed esegue la logica corrispondente: query al database, chiamata API esterna, calcolo locale. Tutta la logica esecutiva risiede nell'applicazione, non nel modello. Questa separazione è ciò che rende il sistema sicuro e controllabile.

Nella quarta fase, la risposta, il risultato dell'esecuzione viene inviato nuovamente a Claude in un nuovo messaggio con ruolo `user` contenente un blocco `tool_result` con l'ID del tool call e il contenuto del risultato. Claude elabora questo risultato e genera la risposta finale per l'utente.

### Best practice per la progettazione dei tool

La qualità delle descrizioni degli strumenti è il fattore più importante per le prestazioni del sistema. Una descrizione vaga porta Claude a usare il tool nei momenti sbagliati o a non usarlo quando sarebbe necessario. Le linee guida raccomandate sono 3-4 frasi che spieghino cosa fa il tool, quando usarlo e cosa restituisce. *(da Building with the Claude API — Building with the Claude API)*

Un principio di design importante è il consolidamento: invece di creare tool separati per ogni operazione correlata (un tool per leggere le PR, uno per creare issue, uno per fare commit), è meglio creare un unico tool `github_manager` con un parametro `action` che specifica l'operazione. Questo riduce il numero di tool che il modello deve considerare, abbassa il token overhead delle definizioni e rende più chiara la relazione tra operazioni correlate.

Il naming segue la convenzione del namespace: `stripe_get_customer`, `notion_create_page`, `sql_execute_query`. Per librerie di strumenti ampie, questo evita ambiguità tra tool con nomi simili e rende immediatamente chiaro a quale servizio appartiene ogni strumento. *(da Building with the Claude API — Building with the Claude API)*

Le risposte dei tool devono essere progettate per restituire solo informazioni ad alto segnale. Restituire l'intero response body di un'API esterna è quasi sempre sbagliato: inquina la finestra di contesto con campi irrilevanti, aumenta il costo e può degradare la qualità delle risposte successive. Il tool deve estrarre e restituire solo i campi rilevanti per il task corrente.

### Programmatic Tool Calling (beta)

Anthropic ha introdotto in beta il Programmatic Tool Calling: una modalità in cui Claude può generare codice Python per orchestrare più chiamate a strumenti in un unico passaggio, invece di richiedere un round-trip separato per ogni tool use. Questo riduce drasticamente la latenza e i costi dei token nei workflow che richiedono sequenze lunghe di tool use, perché il codice generato esegue le chiamate in modo più efficiente di quanto farebbe il loop agentico standard. *(da Building with the Claude API — Building with the Claude API)*

## Esempi concreti

Un tool per la ricerca su database clienti potrebbe essere definito così:

```python
tools = [
    {
        "name": "stripe_get_customer",
        "description": "Recupera i dettagli di un cliente Stripe dato il suo ID o email. Usa questo tool quando l'utente chiede informazioni su un cliente specifico, il suo stato di abbonamento o la sua storia di pagamenti. Restituisce nome, email, stato abbonamento e data di creazione.",
        "input_schema": {
            "type": "object",
            "properties": {
                "customer_id": {
                    "type": "string",
                    "description": "L'ID Stripe del cliente (es. cus_xxx) o l'indirizzo email"
                }
            },
            "required": ["customer_id"]
        }
    }
]
```

Il loop che gestisce il ciclo a quattro fasi:

```python
response = client.messages.create(
    model="claude-3-5-sonnet-20241022",
    max_tokens=1024,
    tools=tools,
    messages=messages
)

if response.stop_reason == "tool_use":
    tool_block = next(b for b in response.content if b.type == "tool_use")
    result = execute_tool(tool_block.name, tool_block.input)
    
    messages.append({"role": "assistant", "content": response.content})
    messages.append({
        "role": "user",
        "content": [{
            "type": "tool_result",
            "tool_use_id": tool_block.id,
            "content": str(result)
        }]
    })
    # Richiama Claude con il risultato
```

*(da Building with the Claude API — Building with the Claude API)*

## Errori comuni e cosa evitare

L'errore più comune è trattare `stop_reason == "tool_use"` come un caso eccezionale da gestire solo se si verifica, invece di progettare il loop agentico attorno ad esso come caso normale. In qualsiasi sistema con tool use, il loop deve essere progettato per gestire sequenze arbitrarie di tool call prima della risposta finale — non solo una singola chiamata. *(da Building with the Claude API — Building with the Claude API)*

Un secondo errore è restituire nei `tool_result` il contenuto grezzo dell'API esterna. Se un'API di ricerca restituisce 50 campi per ogni risultato e ne servono 5, il tool deve filtrare prima di restituire: passare tutto il JSON grezzo nel contesto è uno spreco di token che degrada le risposte e aumenta i costi.

## Connessioni ad altri topic

Questo topic è il meccanismo fondamentale dell'area Agents & MCP. È collegato a **Agentic loop e autonomia** (il tool use come engine del loop), a **Model Context Protocol: architettura** (MCP come standard per esporre tool in modo interoperabile), a **Gestione errori e retry** (la gestione di stop_reason tool_use nei loop lunghi) e a **Pattern di workflow agentici** (i pattern architetturali costruiti sopra il tool use).