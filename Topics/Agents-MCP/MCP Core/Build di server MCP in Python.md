# Build di server MCP in Python

Aggiornato: April 1, 2026 9:31 AM
Categoria: Agents & MCP
Corsi: Claude 101, Intro to MCP, MCP Advanced Topics
Stato: Da Approfondire

> 💬 Il SDK Python di MCP permette di esporre funzioni arbitrarie come tool, resource o prompt in poche decine di righe; la configurazione del client avviene tramite un file JSON che registra il comando di avvio di ogni server.
> 

## Cos'è e perché importa

Comprendere l'architettura MCP a livello concettuale è il primo passo; saperla implementare in Python è il secondo. La distanza tra i due è sorprendentemente breve: il SDK ufficiale astrae la maggior parte del protocollo, lasciando allo sviluppatore solo la logica di dominio da esporre. Un server MCP funzionante per un caso d'uso reale può richiedere meno di 50 righe di codice. *(da Claude 101 — Claude 101)*

## Spiegazione

### Setup dell'ambiente con uv

Per i progetti MCP in Python, l'Anthropic Academy raccomanda `uv` come gestore di dipendenze e ambienti virtuali. Il setup iniziale di un server MCP segue questo pattern:

```bash
uv init mcp-server-demo
cd mcp-server-demo
uv add "mcp[cli]"
```

Il pacchetto `mcp[cli]` installa sia il SDK Python sia gli strumenti da riga di comando. Il requisito minimo è Python 3.10+, necessario per i pattern `async/await` fondamentali nella comunicazione JSON-RPC non bloccante. *(da Introduction to Model Context Protocol — Intro to MCP)*

### FastMCP: l'astrazione ad alto livello

La classe `FastMCP` è il modo principale per creare server con il SDK Python. FastMCP gestisce tutti i dettagli di basso livello del protocollo — serializzazione JSON-RPC, gestione del ciclo di vita, discovery delle capacità — permettendo di concentrarsi sulla logica di business. Il pattern base è istanziare `FastMCP` con il nome del server e decorare le funzioni Python con i decoratori appropriati:

```python
from mcp.server.fastmcp import FastMCP

app = FastMCP("Document-Manager")

@app.tool()
def read_and_summarize(path: str) -> str:
    """
    Legge un documento dal percorso specificato e ne restituisce un riassunto.
    Utilizzare questo tool quando l'utente chiede informazioni su file locali.
    """
    return "Contenuto del documento riassunto..."
```

La docstring non è documentazione opzionale: è la descrizione che il modello leggerà per decidere quando e come invocare il tool. L'SDK usa la riflessione del codice Python per mappare i type hints nei tipi JSON Schema corrispondenti, eliminando la necessità di scrivere schemi JSON manualmente. *(da Introduction to Model Context Protocol — Intro to MCP)*

### Resource Templates con URI parametrizzati

Oltre alle risorse con URI statici, i Resource Templates permettono URI parametrizzati che il modello può costruire dinamicamente. La sintassi usa placeholder tra parentesi graffe nell'URI:

```python
@app.resource("project://{id}/metadata")
def get_project_metadata(id: str) -> str:
    """Recupera i metadati per un progetto specifico via ID."""
    return f"Metadata per il progetto {id}: Stato - Attivo, Priorità - Alta"
```

Questo pattern espone interi namespace di dati con una singola definizione di resource. Il modello può costruire URI specifici senza che il server debba registrare ogni possibile URI individualmente. *(da Introduction to Model Context Protocol — Intro to MCP)*

### Il trasporto stdio in locale

Per server locali, il trasporto stdio è lo standard: il client lancia il server come processo figlio e comunica tramite stdin/stdout. Il server viene avviato e terminato con Claude Desktop, e ogni istanza del client ha la propria istanza del server. È il meccanismo più semplice e sicuro per server che operano su risorse locali. *(da Claude 101 — Claude 101)*

### Avvio con StreamableHTTP per deployment remoti

Per deployment cloud o server accessibili a più client simultaneamente, il trasporto corretto è StreamableHTTP, avviato specificando il parametro `transport` nel metodo `run()`:

```python
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("ProductionServer")

@mcp.tool()
async def calculate_risk(client_id: str, amount: float) -> str:
    """Calcola il rischio finanziario per una transazione."""
    return f"Rischio per {client_id}: Basso"

if __name__ == "__main__":
    mcp.run(transport="streamable-http")
```

L'uso di funzioni `async` è il pattern raccomandato per server che eseguono operazioni I/O: evita di bloccare il loop degli eventi e permette di gestire richieste concorrenti in modo efficiente. *(da Model Context Protocol: Advanced Topics — MCP Advanced Topics)*

### Configurare Claude Desktop

La configurazione del client avviene tramite il file `claude_desktop_config.json` (`~/Library/Application Support/Claude/` su macOS). Ogni entry specifica il nome del server, il comando di avvio e gli argomenti. Le credenziali e i parametri sensibili vanno passati come variabili d'ambiente nella sezione `env`, non hardcodati nel codice sorgente. *(da Claude 101 — Claude 101)*

```json
{
  "mcpServers": {
    "my-server": {
      "command": "python",
      "args": ["/path/to/server.py"],
      "env": { "API_KEY": "..." }
    }
  }
}
```

## Esempi concreti

Un server MCP per un database SQLite locale è il caso d'uso più comune per iniziare: espone la struttura del database come resource e le query come tool. Il server ufficiale `@modelcontextprotocol/server-sqlite` è disponibile via npx ed è pronto all'uso senza scrivere codice, semplicemente registrandolo nel file di configurazione con il percorso al database. *(da Claude 101 — Claude 101)*

## Errori comuni e cosa evitare

Un errore comune nella configurazione è specificare un percorso relativo per il comando nel file di configurazione: Claude Desktop potrebbe essere avviato con una working directory diversa da quella attesa. Usare sempre percorsi assoluti per gli eseguibili e per i file di dati. Un secondo errore è non gestire le eccezioni nel handler `call_tool`: un'eccezione non catturata termina il processo del server, interrompendo tutte le sessioni attive. Ogni tool deve avere un try/except che restituisce un errore strutturato invece di crashare. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic è la realizzazione pratica di **Model Context Protocol: architettura** (il protocollo che il server implementa) e di **Resources, Tools e Prompts in MCP** (le primitive che vengono esposte). È collegato a **MCP Inspector e debugging** (lo strumento per verificare il server durante lo sviluppo), a **StreamableHTTP: il trasporto moderno** (il deployment remoto del server) e a **Gestione errori e retry** (la robustezza del server come componente critico dell'affidabilità del sistema).