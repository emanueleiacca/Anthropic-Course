# Sicurezza avanzata in MCP

Aggiornato: April 1, 2026 2:03 PM
Categoria: Ethics & Safety
Corsi: Intro to MCP, MCP Advanced Topics
Stato: Completo

Fonte: Introduction to Model Context Protocol — Intro to MCP

> 💬 La sicurezza in MCP va oltre la gestione dei permessi generali: il protocollo definisce meccanismi specifici come Roots per il filesystem, proibisce esplicitamente il token passthrough, richiede OAuth 2.1 per identità per-utente, e i client devono proteggersi attivamente contro SSRF e DNS rebinding.
> 

## Cos'è e perché importa

I sistemi MCP operano in una posizione architetturale delicata: si trovano tra il modello AI — che può ricevere input da utenti arbitrari e da contenuti web — e sistemi critici come database aziendali, filesystem, API di terze parti. Questa posizione li rende bersagli naturali di attacchi che cercano di sfruttare la fiducia che il modello ripone nelle istruzioni ricevute. Il corso Intro to MCP tratta la sicurezza come una dimensione architetturale fondamentale, non come un afterthought. *(da Introduction to Model Context Protocol — Intro to MCP)*

## Spiegazione

### Roots: permessi filesystem granulari

Il meccanismo Roots è la risposta di MCP al problema del principio del minimo privilegio applicato all'accesso al filesystem. Invece di dare a un server MCP accesso illimitato al filesystem del sistema host, il client dichiara durante l'handshake una lista esplicita di percorsi autorizzati — le "radici" — all'interno delle quali il server può operare. Il server non può accedere a percorsi al di fuori di questo insieme, anche se il modello tenta di richiedere file in posizioni non autorizzate. *(da Introduction to Model Context Protocol — Intro to MCP)*

Questo fornisce un confine di sicurezza invalicabile a livello di protocollo, non solo a livello applicativo. Un server che rispetta il protocollo non può — nemmeno se lo volesse — accedere a file fuori dalle Roots dichiarate dal client. All'interno delle Roots, il modello può scoprire file e directory in modo dinamico, mantenendo la flessibilità operativa senza sacrificare la sicurezza.

Il client può anche dichiarare che le sue Roots sono soggette a cambiamento (`listChanged: true`), permettendo di aggiornare dinamicamente i permessi di accesso durante la sessione in risposta a scelte esplicite dell'utente.

### Prevenzione SSRF: blocco degli IP privati

I client MCP devono proteggersi contro attacchi di Server-Side Request Forgery (SSRF). Questo tipo di attacco si manifesta quando un server MCP malevolo o compromesso tenta di fare in modo che il client esegua richieste verso risorse interne che normalmente non sarebbero accessibili dall'esterno. Un server potrebbe, ad esempio, fornire un URI di resource che punta a un endpoint di metadati cloud (come `169.254.169.254` su AWS) per esfiltrare credenziali dell'infrastruttura. *(da Introduction to Model Context Protocol — Intro to MCP)*

Le protezioni necessarie includono il blocco preventivo di richieste verso intervalli di IP privati: `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16` (indirizzi di rete locale) e `169.254.0.0/16` (link-local, dove risiedono gli endpoint di metadati cloud). Questi blocchi devono essere implementati nel client, non nel server, perché è il client che esegue fisicamente le richieste.

I server HTTP devono anche implementare protezione contro il DNS rebinding: un attacco in cui un dominio risolve inizialmente in un IP pubblico (superando i controlli di sicurezza) e poi re-risolve in un IP privato al momento della richiesta effettiva.

### Il divieto di token passthrough

Uno degli anti-pattern di sicurezza più pericolosi — e che il protocollo MCP proibisce esplicitamente — è il "token passthrough": la pratica di un server MCP di accettare un token di autenticazione dal client e passarlo direttamente a un'API downstream senza validarlo. *(da Introduction to Model Context Protocol — Intro to MCP)*

Il problema è fondamentale: se il server accetta semplicemente qualsiasi token e lo passa avanti, non c'è modo di verificare che il token sia stato emesso per quel server specifico, non c'è modo di limitare l'ambito delle azioni consentite, e non c'è modo di tracciare chi ha eseguito quale azione. Il protocollo MCP richiede che i token siano emessi specificamente per il server MCP che li riceve — non token generici riusati tra servizi diversi. Questo garantisce tracciabilità e gestione granulare degli accessi.

### OAuth 2.1 per identità per-utente

L'uso di token statici condivisi tra tutti gli utenti di un server MCP è un anti-pattern documentato con conseguenze gravi: rende impossibile l'auditing per singolo utente, complica la rotazione delle credenziali e non permette di revocare l'accesso a singoli utenti senza impattare tutti gli altri. *(da Introduction to Model Context Protocol — Intro to MCP)*

La soluzione raccomandata è implementare OAuth 2.1 per l'autenticazione per-utente. Con OAuth 2.1, ogni utente si autentica individualmente e ottiene un token specifico per quella sessione. Questo permette l'auditing granulare (chi ha fatto cosa e quando), la revoca individuale degli accessi, e l'applicazione di policy di autorizzazione per utente invece che per server.

### Validazione degli input con Pydantic

Non fidarsi mai degli input ricevuti dal modello come se fossero già validati. Il modello può inviare argomenti mal formati, fuori range, o deliberatamente costruiti per sfruttare vulnerabilità nelle operazioni downstream (SQL injection, path traversal, command injection). La soluzione è validare rigorosamente ogni parametro in arrivo usando modelli Pydantic prima di usarli in chiamate a database, filesystem o shell. *(da Introduction to Model Context Protocol — Intro to MCP)*

```python
from pydantic import BaseModel, validator
from mcp.server.fastmcp import FastMCP

app = FastMCP("Secure-Server")

class QueryParams(BaseModel):
    table: str
    limit: int
    
    @validator('table')
    def table_must_be_allowlisted(cls, v):
        allowed = {'users', 'products', 'orders'}
        if v not in allowed:
            raise ValueError(f'Tabella non autorizzata: {v}')
        return v
    
    @validator('limit')
    def limit_must_be_reasonable(cls, v):
        if v < 1 or v > 1000:
            raise ValueError('Limit fuori range consentito')
        return v

@app.tool()
def query_database(table: str, limit: int) -> str:
    """Esegue una query su una tabella autorizzata."""
    params = QueryParams(table=table, limit=limit)  # Validazione
    # Procede solo se la validazione passa
    return execute_safe_query(params.table, params.limit)
```

*(da Introduction to Model Context Protocol — Intro to MCP)*

### DNS Rebinding over SSE: il vettore specifico delle connessioni locali

Il corso MCP Advanced Topics identifica un vettore di attacco specifico per i server MCP che usano connessioni SSE locali. L'attacco sfrutta la natura delle connessioni SSE di lunga durata: un sito web malevolo registra un dominio che inizialmente risolve in un IP pubblico, poi riconfigura il DNS per farlo risolvere verso `localhost` o un IP interno. Il browser, avendo già stabilito la connessione SSE, continua a comunicare con il nuovo indirizzo come se fosse lo stesso origine fidato. *(da Model Context Protocol: Advanced Topics — MCP Advanced Topics)*

La mitigazione principale è la validazione rigorosa dell'header `Origin` su tutte le connessioni in entrata: il server deve verificare che l'Origin corrisponda ai valori attesi e rifiutare le connessioni non autorizzate. Per i server che usano StreamableHTTP invece di SSE, questo vettore è meno rilevante — ed è una delle ragioni per preferire StreamableHTTP per i deployment moderni.

### OAuth 2.1 con PKCE come standard mandatorio

Per i trasporti HTTP remoti, il corso MCP Advanced Topics eleva OAuth 2.1 con PKCE da raccomandazione a requisito mandatorio. Il PKCE (Proof Key for Code Exchange) protegge il flusso di autorizzazione anche su canali non sicuri, prevenendo l'intercettazione del codice di autorizzazione. In un'architettura MCP multi-tenant, dove lo stesso server serve molti utenti distinti, OAuth 2.1 con PKCE garantisce che ogni sessione sia autenticata individualmente e che i token siano legati all'utente che li ha ottenuti. *(da Model Context Protocol: Advanced Topics — MCP Advanced Topics)*

Il requisito di consenso esplicito si applica in particolare alle operazioni distruttive: le applicazioni host devono mostrare chiaramente i comandi che stanno per essere eseguiti e richiedere l'approvazione dell'utente prima di procedere.

## Errori comuni e cosa evitare

L'errore più comune è implementare la sicurezza solo a livello di prompt ("istruisco il modello a non fare X") invece che a livello architetturale. Le istruzioni nel prompt non sono un meccanismo di sicurezza affidabile: possono essere aggirate da prompt injection o semplicemente ignorate in casi limite. La sicurezza deve essere implementata nei componenti che eseguono le azioni — il server MCP — non solo nelle istruzioni che guidano il modello. *(da Introduction to Model Context Protocol — Intro to MCP)*

Un secondo errore frequente è usare token statici condivisi per comodità durante lo sviluppo e poi portarli in produzione senza cambiarli. I token di sviluppo devono essere esplicitamente diversi da quelli di produzione, e il sistema di autenticazione deve essere progettato per supportare identità per-utente fin dall'inizio, non aggiunto come retrofit.

## Connessioni ad altri topic

Questo topic è la specializzazione MCP-specifica di **Sicurezza nei sistemi agentici** (i principi generali applicati al protocollo MCP), collegato a **Ciclo di vita della connessione MCP e handshake** (le Roots vengono dichiarate durante l'handshake), a **Build di server MCP in Python** (la validazione Pydantic come pratica di sicurezza nell'implementazione), e a **Responsible use e bias** (la sicurezza come dimensione del responsible use nei sistemi agentici).