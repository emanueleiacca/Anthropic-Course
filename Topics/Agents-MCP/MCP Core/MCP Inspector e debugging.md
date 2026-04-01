# MCP Inspector e debugging

Aggiornato: April 1, 2026 2:03 PM
Categoria: Agents & MCP
Corsi: Intro to MCP
Stato: Completo

Fonte: Introduction to Model Context Protocol — Intro to MCP

> 💬 L'MCP Inspector è lo strumento di sviluppo dedicato per testare server MCP in isolamento: permette di invocare tool, visualizzare resource, fare preview di prompt e monitorare il flusso di messaggi senza dover integrare un host completo come Claude Desktop.
> 

## Cos'è e perché importa

Debuggare sistemi basati su protocolli asincroni come MCP è intrinsecamente complesso: la comunicazione avviene tramite messaggi JSON-RPC, il server gira come processo separato, e gli errori possono manifestarsi in qualsiasi punto del flusso di inizializzazione, discovery o esecuzione. Tentare di debuggare un server MCP direttamente integrato in Claude Desktop significa avere pochissima visibilità su cosa sta succedendo — solo il comportamento esterno dell'applicazione. L'MCP Inspector risolve questo problema fornendo un ambiente di test isolato con visibilità completa su ogni messaggio scambiato. *(da Introduction to Model Context Protocol — Intro to MCP)*

Il corso Intro to MCP descrive l'Inspector come il "primo punto di sosta" per ogni sviluppatore MCP: prima di integrare il server in un host reale, si verifica che funzioni correttamente in isolamento.

## Spiegazione

### Funzionalità principali dell'Inspector

L'MCP Inspector è un'interfaccia web che si connette direttamente al server MCP in fase di sviluppo, senza richiedere un host AI come intermediario. Offre tre aree funzionali distinte. *(da Introduction to Model Context Protocol — Intro to MCP)*

La prima area è il test dei tool: l'Inspector visualizza gli schemi JSON generati automaticamente dai decoratori Python e permette di invocare i tool con argomenti personalizzati, osservando direttamente il risultato. Questo è fondamentale per verificare che la docstring venga letta correttamente come descrizione operativa, che i type hints vengano mappati nei tipi JSON Schema attesi, e che la logica del tool produca l'output corretto.

La seconda area è la preview dei prompt: permette di testare i template definiti nel server inserendo le variabili richieste e verificando l'output generato prima che venga inviato al modello, raffinando i template senza dover avviare conversazioni reali con l'AI.

La terza area è il monitoraggio delle notifiche: visualizza in tempo reale il flusso completo di messaggi, inclusi i log su stderr e le notifiche di sistema. Rende visibile ogni step del protocollo — dall'handshake alle risposte dei tool — permettendo di identificare esattamente dove un flusso devia dal comportamento atteso.

### Avvio dell'Inspector

L'Inspector viene avviato tramite gli strumenti CLI installati con il pacchetto `mcp[cli]`:

```bash
# Avvio dell'Inspector puntando al server locale
mcp dev server.py
```

Il comando avvia il server come sottoprocesso e lancia l'interfaccia web dell'Inspector nella porta di default. L'Inspector si connette al server tramite il trasporto STDIO, esattamente come farebbe un host reale, garantendo che il comportamento osservato sia identico a quello che si avrebbe in produzione. *(da Introduction to Model Context Protocol — Intro to MCP)*

### Debugging in produzione: log di Claude Desktop

Quando il server è integrato in un host reale come Claude Desktop, le strategie di debugging cambiano necessariamente. Il primo strumento da consultare sono i log dell'applicazione host, che si trovano in percorsi specifici a seconda del sistema operativo: su macOS in `~/Library/Logs/Claude`, su Windows in `%APPDATA%\Claude\logs`. Questi log contengono i messaggi di errore generati durante l'avvio dei server MCP, gli errori di connessione, e le eccezioni non gestite. *(da Introduction to Model Context Protocol — Intro to MCP)*

Una regola critica e frequentemente violata: i server STDIO non devono mai scrivere messaggi di log o di debug su stdout. Lo stdout è il canale riservato ai messaggi JSON-RPC del protocollo; qualsiasi testo non-JSON scritto su stdout corrompe il flusso di messaggi e causa il crash immediato della connessione. Tutti i log devono essere diretti a stderr, o inviati tramite il meccanismo di logging strutturato del protocollo MCP. *(da Introduction to Model Context Protocol — Intro to MCP)*

### Il ciclo di sviluppo STDIO e il riavvio obbligatorio

Un dettaglio operativo critico per chi sviluppa server STDIO: a differenza delle API web dove le modifiche al codice vengono caricate a caldo, le modifiche a un server MCP STDIO richiedono un riavvio completo dell'host per essere caricate. L'host (Claude Desktop) avvia il processo del server all'apertura della sessione e lo mantiene attivo fino alla chiusura. Modificare il codice del server e aspettarsi di vedere il nuovo comportamento senza riavviare l'host è l'errore più comune durante lo sviluppo. *(da Introduction to Model Context Protocol — Intro to MCP)*

L'Inspector non ha questo problema perché lancia il server come sottoprocesso fresco ad ogni avvio: è uno dei motivi principali per cui è preferibile usarlo durante lo sviluppo invece di testare direttamente in Claude Desktop.

## Esempi concreti

Un workflow di sviluppo tipico con l'Inspector procede in questo modo. Si scrive la funzione Python con il decoratore `@app.tool()` e la docstring, poi si avvia `mcp dev server.py` per lanciare l'Inspector. Nella sezione Tools si verifica che lo schema JSON generato corrisponda all'atteso. Si invoca il tool con argomenti di test e si verifica l'output nella sezione risultati. Si controlla il pannello Notifiche per confermare che il logging avvenga su stderr e non su stdout. Solo dopo aver verificato tutto in isolamento, si registra il server nel `claude_desktop_config.json` e si riavvia Claude Desktop. *(da Introduction to Model Context Protocol — Intro to MCP)*

## Errori comuni e cosa evitare

L'errore più comune è saltare la fase di test con l'Inspector e integrare direttamente il server in Claude Desktop. Questo porta a cicli di debugging frustranti: si modifica il server, si riavvia Claude Desktop, si testa nell'interfaccia chat, si ottiene un comportamento inatteso, non si capisce se il problema è nel server o nel prompt, si riavvia ancora. Con l'Inspector, ogni step del protocollo è visibile e il debugging è molto più rapido. *(da Introduction to Model Context Protocol — Intro to MCP)*

Un secondo errore è usare `print()` in Python per il debugging: in un server STDIO, `print()` scrive su stdout per default, corrompendo il flusso JSON-RPC. Usare sempre `import sys; print('debug', file=sys.stderr)` o il logging strutturato MCP.

## Connessioni ad altri topic

Questo topic è strettamente collegato a **Build di server MCP in Python** (l'Inspector come ambiente di verifica dello sviluppo), a **Ciclo di vita della connessione MCP e handshake** (l'Inspector rende visibile l'intero handshake), a **Gestione errori e retry** (i log di Claude Desktop come strumento diagnostico) e a **Sampling e notifiche MCP** (il pannello notifiche dell'Inspector per monitorare il flusso di messaggi).