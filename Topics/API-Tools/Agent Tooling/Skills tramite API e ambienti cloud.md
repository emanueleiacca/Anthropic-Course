# Skills tramite API e ambienti cloud

Aggiornato: March 31, 2026 8:35 PM
Categoria: API & Tools
Corsi: Intro to Agent Skills
Stato: Completo

Fonte: Introduction to Agent Skills — Intro to Agent Skills

> 💬 Le Agent Skills sono accessibili non solo tramite Claude Code ma anche via API Messages con header beta specifici: questo abilita scenari enterprise dove Skills di generazione documenti, analisi dati e workflow complessi vengono integrate direttamente in applicazioni Java, Python o qualsiasi client HTTP.
> 

## Cos'è e perché importa

Nell'ecosistema Claude Code, le Skills sono un meccanismo locale: file Markdown che l'agente legge dal filesystem o dal repository. Ma le Skills sono anche accessibili tramite l'API Messages di Anthropic, abilitando scenari molto diversi: integrazioni in applicazioni esistenti, deployment in ambienti cloud senza Claude Desktop, utilizzo da framework enterprise come Spring AI. Questa seconda modalità d'uso richiede una configurazione API specifica e ha caratteristiche operative diverse da quella locale. *(da Introduction to Agent Skills — Intro to Agent Skills)*

## Spiegazione

### I tre header beta obbligatori

L'uso delle Skills via API richiede l'attivazione di tre header beta specifici che abilitano l'infrastruttura di esecuzione del codice e la gestione dei file. Questi header devono essere inclusi in ogni richiesta che usa le Skills. *(da Introduction to Agent Skills — Intro to Agent Skills)*

`code-execution-2025-08-25` abilita l'esecuzione di script nel container sandbox isolato. È necessario perché le Skills, a differenza dei semplici prompt, operano spesso in un ambiente dove possono eseguire codice Python o Node.js.

`skills-2025-10-02` abilita le funzionalità specifiche del framework Skills, permettendo all'API di riconoscere e gestire i file [SKILL.md](http://SKILL.md) e la struttura directory associata.

`files-api-2025-04-14` abilita l'upload e il download di file tra il client e il container sandbox. Questo è necessario quando le Skills generano file come output — documenti Excel, PDF, presentazioni PowerPoint — che devono essere recuperati dal client.

### Il tool code_execution come prerequisito

Oltre agli header beta, ogni richiesta API che usa le Skills deve includere il tool `code_execution` nell'array dei tool disponibili. Non è sufficiente includere gli header: senza questo tool dichiarato, le Skills che contengono script non possono eseguire il codice nel sandbox. *(da Introduction to Agent Skills — Intro to Agent Skills)*

Un esempio di struttura di richiesta:

```python
import anthropic

client = anthropic.Anthropic()

response = client.messages.create(
    model="claude-opus-4-6",
    max_tokens=4096,
    tools=[{"type": "code_execution"}],  # Obbligatorio per le Skills
    extra_headers={
        "anthropic-beta": "code-execution-2025-08-25,skills-2025-10-02,files-api-2025-04-14"
    },
    messages=[{
        "role": "user",
        "content": "Genera una presentazione PowerPoint sui nostri KPI del Q3"
    }],
    # Skills caricate tramite Files API
)
```

*(da Introduction to Agent Skills — Intro to Agent Skills)*

### Persistenza dei file e scope workspace

I file generati dalle Skills tramite API hanno una validità limitata a 24 ore prima di essere eliminati automaticamente dal Files API di Anthropic. Questo ha implicazioni importanti per il design del sistema: l'applicazione client deve recuperare i file generati (documenti, report, presentazioni) entro 24 ore dall'esecuzione, o implementare una logica di ri-generazione.

Un'altra differenza rispetto all'uso locale riguarda lo scope delle Skills caricate. Tramite API, le Skills caricate sono accessibili a livello di workspace: tutti i membri del team possono vederle e usarle. Questo contrasta con l'uso tramite [Claude.ai](http://Claude.ai), dove ogni utente deve caricare le proprie Skills individualmente. Per ambienti enterprise, il comportamento workspace-level è vantaggioso: una Skill di generazione report viene caricata una volta dall'amministratore e diventa disponibile a tutto il team senza configurazione individuale. *(da Introduction to Agent Skills — Intro to Agent Skills)*

### Integrazione con framework enterprise: Spring AI

L'adozione industriale delle Skills tramite API è testimoniata dal supporto in framework enterprise come Spring AI. Questi strumenti astraggono la complessità della gestione degli header beta e del parsing delle risposte JSON annidate, fornendo classi specializzate come `AnthropicSkill` e gestori automatici per il download dei file generati. *(da Introduction to Agent Skills — Intro to Agent Skills)*

Questo permette agli sviluppatori Java di integrare capacità di generazione documenti — PowerPoint, Word, Excel — prodotte da Claude direttamente nelle loro applicazioni aziendali, senza dover gestire manualmente i dettagli del protocollo API. L'esistenza di questo supporto in un framework maturo come Spring AI segnala che le Skills tramite API sono considerate una funzionalità di produzione stabile, non un esperimento.

## Esempi concreti

Uno scenario tipico: un'applicazione di reporting aziendale che usa una Skill per generare presentazioni PowerPoint dai dati del CRM. Il backend Python carica la Skill `pptx-generator` tramite Files API, invia la richiesta di generazione con i dati del Q3, e dopo l'esecuzione recupera il file PPTX generato dalla sandbox prima che scada il timeout di 24 ore. Il file viene poi salvato nel sistema di storage aziendale (S3, SharePoint) per accesso persistente. *(da Introduction to Agent Skills — Intro to Agent Skills)*

## Errori comuni e cosa evitare

L'errore più comune è dimenticare uno dei tre header beta. Se manca `files-api`, le Skills che generano file non riescono a salvare l'output e producono errori criptici. Se manca `skills`, il framework non riconosce la struttura [SKILL.md](http://SKILL.md) e tratta il file come testo normale. La verifica sistematica della presenza di tutti e tre gli header deve essere parte del checklist di setup. *(da Introduction to Agent Skills — Intro to Agent Skills)*

Un secondo errore è non gestire la scadenza dei file. Un sistema che genera documenti tramite Skills API e assume che i file siano disponibili indefinitamente sarà interrotto dopo 24 ore. Il download e il salvataggio persistente dei file generati deve essere parte del flusso immediato post-esecuzione, non un'attività differibile.

## Connessioni ad altri topic

Questo topic è l'estensione API di **Agent Skills in Claude Code** (le Skills nel loro contesto nativo), collegato a **Messages API: struttura e parametri** (la chiamata API in cui vengono inclusi gli header beta) e a **Anatomia di una Skill: [SKILL.md](http://SKILL.md) e frontmatter** (la struttura del file che viene caricata tramite Files API).