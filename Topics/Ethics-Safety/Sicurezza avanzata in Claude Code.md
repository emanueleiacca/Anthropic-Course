# Sicurezza avanzata in Claude Code

Aggiornato: April 1, 2026 2:14 PM
Categoria: Ethics & Safety
Corsi: Claude Code in Action
Stato: Completo

Fonte: Claude Code in Action — Claude Code in Action

> 💬 La sicurezza di Claude Code si articola su tre livelli: la gerarchia Deny/Ask/Allow per la configurazione granulare dei permessi, una strategia di hardening in sette fasi per gli ambienti enterprise, e la difesa attiva contro minacce emergenti come le malicious skills e il prompt injection via codice.
> 

## Cos'è e perché importa

Un agente con accesso al filesystem locale, ai comandi shell e a servizi esterni è intrinsecamente un sistema ad alto privilegio. La superficie di attacco è significativamente più ampia di quella di un chatbot: include file di configurazione, chiavi API, repository di codice, e potenzialmente l'intera rete aziendale se le credenziali cloud sono configurate localmente. Il corso Claude Code in Action tratta la sicurezza come una dimensione architetturale fondamentale, non come una configurazione opzionale post-installazione. *(da Claude Code in Action — Claude Code in Action)*

## Spiegazione

### Gerarchia Deny > Ask > Allow: il principio Zero Trust

La configurazione dei permessi in Claude Code segue una gerarchia a tre livelli con precedenza esplicita. *(da Claude Code in Action — Claude Code in Action)*

La Denylist è il livello massimo, definita "nuclear shield": deve bloccare categoricamente l'accesso a directory sensibili e comandi pericolosi senza eccezioni. Le directory da denylistare includono `~/.ssh/`, `~/.aws/`, `~/.gcloud/`, e qualsiasi directory con file `.env`. I comandi da bloccare includono `curl` e `wget` (che possono esfiltrare dati), `rm -rf /` e varianti, e qualsiasi comando di esecuzione remota non supervisionata.

L'Asklist è lo stato predefinito raccomandato: comandi con effetti esterni come `git push`, `docker run`, `kubectl apply` devono richiedere l'approvazione esplicita dell'utente prima dell'esecuzione. L'agente mostra il comando e attende conferma, creando un punto di controllo umano per tutte le operazioni con conseguenze esterne al sistema locale.

L'Allowlist deve contenere solo comandi di sola lettura e intrinsecamente sicuri: `ls`, `cat` con restrizioni di path, `grep`, `find`. L'obiettivo è ridurre il carico cognitivo dello sviluppatore per operazioni ripetitive e innocue, senza aprire vettori di rischio. *(da Claude Code in Action — Claude Code in Action)*

### Minacce emergenti: malicious skills e prompt injection

La ricerca citata nel corso ha identificato oltre 650 Skills malevole capaci di eseguire pattern di auto-esecuzione o iniezioni Unicode per nascondere comandi distruttivi. L'attacco funziona inserendo istruzioni malevole in file di codice, documentazione, o pagine web che l'agente legge durante il suo lavoro: il modello può interpretare queste istruzioni come comandi legittimi e eseguirle con i propri privilegi. *(da Claude Code in Action — Claude Code in Action)*

Casi documentati includono: file di codice che contengono commenti con istruzioni per esfiltrare il contenuto di file `.env` verso URL esterni; pagine web che istruiscono l'agente a installare package npm malevoli; template di progetto che includono hook Git pre-commit con codice dannoso.

La difesa principale è la combinazione di Denylist (blocca le azioni più pericolose anche se il modello viene istruito a eseguirle) e Defender Hooks PostToolUse (scansionano l'output dei tool per rilevare pattern di injection prima che raggiungano il modello).

### Strategia di hardening in sette fasi per ambienti enterprise

Per deployment di produzione, il corso documenta una strategia di hardening progressiva. *(da Claude Code in Action — Claude Code in Action)*

Il primo passo è l'isolamento dell'ambiente: eseguire Claude Code all'interno di container Docker o macchine virtuali limita il raggio d'azione in caso di compromissione. Il secondo passo è lo scaricamento dei privilegi: non eseguire mai Claude Code con utente root, poiché l'agente eredita i permessi del processo genitore. Il terzo passo è il credential scrubbing: Hook di PreToolUse che analizzano i comandi prima dell'esecuzione per bloccare tentativi di lettura di file contenenti segreti (`.env`, `.pem`, `credentials`, `~/.ssh/`, `~/.aws/`). *(da Claude Code in Action — Claude Code in Action)*

Il quarto passo è l'audit continuo: monitorare regolarmente il file `managed-settings.json` per rilevare config drift — cambiamenti non autorizzati alle policy che potrebbero indicare compromissione. Il quinto passo è la rotazione regolare delle chiavi API: pianificata, non reattiva, con scadenza esplicita. Il sesto passo è la limitazione della rete: permettere a Claude Code di raggiungere solo gli endpoint necessari (API Anthropic, server MCP autorizzati), bloccando l'accesso a domini arbitrari. Il settimo passo è il logging e l'osservabilità: centralizzare i log di tutte le sessioni in un sistema di audit immutabile con timestamp, utente, comando e risultato per ogni operazione.

## Esempi concreti

Una configurazione di `managed-settings.json` per un team di sviluppo con politica Zero Trust:

```json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf*)",
      "Bash(curl*)",
      "Bash(wget*)",
      "Read(~/.ssh/*)",
      "Read(~/.aws/*)",
      "Read(**/.env)"
    ],
    "ask": [
      "Bash(git push*)",
      "Bash(docker*)",
      "Bash(kubectl*)",
      "Write(**)"
    ],
    "allow": [
      "Bash(ls*)",
      "Bash(grep*)",
      "Read(./src/**)",
      "Read(./tests/**)"
    ]
  }
}
```

*(da Claude Code in Action — Claude Code in Action)*

## Errori comuni e cosa evitare

L'errore più comune è configurare la Denylist solo per le minacce ovvie (come `rm -rf /`) e trascurare i vettori di esfiltrazione più sottili. `curl` e `wget` usati in modo malevolo sono spesso più pericolosi di un comando di cancellazione file: possono inviare dati sensibili a server remoti senza lasciare tracce ovvie nel filesystem locale. La Denylist deve essere pensata sia per le operazioni distruttive sia per le operazioni di esfiltrazione. *(da Claude Code in Action — Claude Code in Action)*

Un secondo errore è trattare la sicurezza come configurazione iniziale e non come processo continuo. L'audit del `managed-settings.json` deve essere periodico, non una-tantum. I team che crescono, i nuovi server MCP aggiunti, e gli aggiornamenti di Claude Code possono tutti modificare la superficie di attacco in modo non ovvio.

## Connessioni ad altri topic

Questo topic è la specializzazione Claude Code di **Sicurezza nei sistemi agentici** (che tratta i principi generali) e di **Sicurezza avanzata in MCP** (che tratta i meccanismi specifici del protocollo MCP). È collegato a **Hooks nel ciclo di vita degli agenti** (i Defender Hooks come meccanismo di difesa attiva), a **Setup e installazione di Claude Code** (la configurazione delle policy avviene subito dopo l'installazione) e a **Responsible use e bias** (il responsible use in ambienti con agenti ad alto privilegio).