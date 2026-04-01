# Sampling e notifiche MCP

Aggiornato: April 1, 2026 9:32 AM
Categoria: Agents & MCP
Corsi: Intro to MCP, MCP Advanced Topics
Stato: Completo

> 💬 Il sampling permette ai server MCP di richiedere completamenti al modello dell'host invece di gestire proprie chiavi API; le notifiche di progresso abilitano comunicazione asincrona durante operazioni lunghe; il logging strutturato RFC 5424 fornisce visibilità granulare sullo stato del server.
> 

## Cos'è e perché importa

In un'architettura MCP standard, il flusso è unidirezionale: il modello dell'host chiede al server di fare qualcosa, il server esegue e risponde. Tuttavia, ci sono scenari dove il server stesso ha bisogno di ragionamento linguistico durante l'esecuzione di un task complesso. Il sampling inverte questo flusso in modo controllato, permettendo al server di delegare decisioni al modello senza dover gestire autonomamente le chiavi API e i costi di inferenza. *(da Introduction to Model Context Protocol — Intro to MCP)*

## Spiegazione

### Sampling: il server chiede al client di ragionare

Il sampling è una capacità opzionale che il client dichiara durante l'handshake. Quando abilitato, permette al server MCP di inviare una richiesta di completamento al client, che la esegue usando il proprio modello e restituisce il risultato al server. Il flusso è: il server riceve una richiesta dal modello → durante l'elaborazione ha bisogno di una decisione complessa → invia una richiesta di sampling al client → il client chiama il modello e restituisce la risposta → il server usa la risposta per completare l'elaborazione. *(da Introduction to Model Context Protocol — Intro to MCP)*

Questo pattern offre un vantaggio economico e architetturale significativo: i costi delle chiamate AI e la gestione delle chiavi API rimangono sul client. Un server MCP può quindi offrire capacità di ragionamento avanzate senza dover essere un servizio AI autonomo con la propria infrastruttura di inferenza.

### Parametri completi della richiesta sampling/createMessage

Il corso MCP Advanced Topics documenta l'intera firma della richiesta di sampling. Il parametro `messages` è l'array della cronologia con ruoli user/assistant e contenuti che possono includere testo e immagini. Il parametro `modelPreferences` permette di indicare preferenze per la selezione del modello: hints sul nome desiderato e priorità tra intelligenza, velocità e costo. Il parametro `systemPrompt` permette al server di definire istruzioni specifiche per quel campionamento, indipendentemente dal system prompt dell'host. Il parametro `includeContext` specifica se includere contesto dal server corrente, da tutti i server connessi o nessuno. Il parametro `temperature` controlla la casualità della generazione. *(da Model Context Protocol: Advanced Topics — MCP Advanced Topics)*

### Sampling multi-turno con tool use ricorsivo

L'architettura avanzata del sampling supporta flussi di lavoro agentici ricorsivi: il server può includere un array di `tools` nella richiesta di sampling, permettendo al modello di chiamare funzioni specifiche durante il campionamento. Se il modello risponde con `stopReason: "toolUse"`, il server esegue il tool, raccoglie il risultato e invia una successiva richiesta di sampling per continuare l'elaborazione. Questo pattern crea loop agentici in cui il server agisce come supervisore della logica di dominio, delegando il ragionamento al modello. *(da Model Context Protocol: Advanced Topics — MCP Advanced Topics)*

Un vincolo di sicurezza critico imposto dalla specifica: i server devono inviare richieste di sampling solo in associazione a una richiesta originaria del client. Il sampling proattivo non sollecitato è proibito perché potrebbe violare la privacy dell'utente o generare costi inaspettati.

### Tracciamento del progresso con progressToken

Per le operazioni a lunga esecuzione, il client avvia l'operazione includendo un `progressToken` opaco nel campo `_meta` della richiesta. Il server usa questo token per inviare notifiche `notifications/progress` periodiche che indicano il valore corrente, il totale previsto e un messaggio descrittivo. La UI può usare questi dati per mostrare barre di caricamento precise o messaggi di stato dinamici, riducendo la percezione di latenza in operazioni che durano decine di secondi. *(da Model Context Protocol: Advanced Topics — MCP Advanced Topics)*

### Notifiche di progresso per operazioni lunghe

Per operazioni che richiedono tempo significativo, il protocollo supporta l'invio di token di progresso tramite Notification MCP: messaggi unidirezionali che non richiedono risposta. Il server invia notifiche con percentuale di completamento o descrizione dello step corrente, e il client le visualizza nel modo più appropriato. Dato che le notifiche sono unidirezionali, non bloccano il flusso principale dell'elaborazione. *(da Introduction to Model Context Protocol — Intro to MCP)*

### Logging strutturato con livelli RFC 5424

Il protocollo definisce un sistema di logging strutturato basato sui livelli di severità RFC 5424. Dal meno al più critico: debug, info, notice, warning, error, critical, alert, emergency. Una regola critica per server STDIO: i messaggi di log non devono mai essere scritti su stdout — devono usare stderr o le notifiche di logging del protocollo. Scrivere testo informativo su stdout corrompe il flusso JSON-RPC e causa il crash della connessione. *(da Introduction to Model Context Protocol — Intro to MCP)*

## Esempi concreti

Un server di analisi documentale che usa il sampling per prendere decisioni classificatorie: il server riceve un documento, lo elabora estraendo le sezioni principali, poi usa il sampling per chiedere al modello dell'host di classificare le sezioni in categorie, e infine aggrega le classificazioni in un report strutturato. L'intero ragionamento classificatorio avviene sul modello dell'host, mentre il server gestisce solo l'I/O documentale. *(da Introduction to Model Context Protocol — Intro to MCP)*

## Errori comuni e cosa evitare

Un errore comune è implementare il sampling senza verificare che il client lo supporti. Il sampling è una capacità opzionale: non tutti i client MCP la implementano. Un server che invia richieste di sampling a un client che non le supporta riceve un errore. La verifica deve avvenire durante la fase di handshake controllando le capacità dichiarate dal client. *(da Introduction to Model Context Protocol — Intro to MCP)*

## Connessioni ad altri topic

Questo topic è collegato a **Ciclo di vita della connessione MCP e handshake** (il sampling viene negoziato durante l'handshake), ad **Agentic loop e autonomia** (il sampling come meccanismo per delegare ragionamento in loop agentici complessi) e a **MCP Inspector e debugging** (il monitoraggio delle notifiche come strumento di ispezione del flusso).