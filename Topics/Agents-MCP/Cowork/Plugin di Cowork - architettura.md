# Plugin di Cowork: architettura e personalizzazione

Aggiornato: April 1, 2026 2:06 PM
Categoria: Agents & MCP
Corsi: Intro to Claude Cowork
Stato: Completo

Fonte: Introduction to Claude Cowork — Intro to Claude Cowork

> 💬 Un Plugin di Cowork è un pacchetto integrato che raggruppa Skills Markdown, connettori MCP e Slash Commands per una funzione lavorativa specifica: è la unità di composizione che trasforma Cowork da strumento generico a specialista di dominio configurabile senza scrivere codice.
> 

## Cos'è e perché importa

La potenza di un agente non dipende solo dal modello sottostante, ma dalla qualità delle istruzioni, degli strumenti e dei comportamenti predefiniti che lo guidano. In Cowork, il Plugin è il meccanismo attraverso cui queste tre dimensioni vengono impacchettate in un'unità coerente e riutilizzabile. Un'azienda può costruire un Plugin per l'ufficio finance con le procedure di riconciliazione contabile, le connessioni ai sistemi ERP e i comandi per i report periodici; un altro Plugin per il team legal con la terminologia contrattuale, l'accesso al repository documenti e i flussi di revisione standard. Ogni Plugin trasforma Cowork in uno specialista di quel dominio. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

La scelta progettuale di basare tutto su file Markdown e JSON — invece di un sistema di build complesso — è deliberata: permette a utenti con competenze tecniche moderate di creare, modificare e distribuire Plugin senza infrastrutture dedicate.

## Spiegazione

### Le quattro componenti di un Plugin

Ogni Plugin è strutturato come una cartella che contiene file con ruoli specifici e complementari. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

Il file `plugin.json` è il manifesto: definisce il nome del Plugin, la versione, la descrizione e le dipendenze da altri Plugin o server. È il punto di ingresso che Cowork legge per capire cosa contiene e come caricare il Plugin.

Il file `.mcp.json` è la configurazione dei connettori: specifica quali server MCP attivare quando il Plugin è in uso, con le credenziali di autenticazione (tipicamente riferimenti a variabili d'ambiente) e i parametri di configurazione. Un Plugin finance potrebbe attivare il connettore per Xero, quello per Snowflake e quello per Google Sheets tutti insieme.

Le Skills sono file Markdown che contengono istruzioni di dominio, best practice, terminologia aziendale e procedure operative. Claude carica automaticamente il contenuto rilevante quando il contesto del task corrisponde alla descrizione della Skill — un meccanismo di selezione contestuale, non un caricamento monolitico. Un Plugin per l'internal audit con tre Skills separate (procedure SOX 404, classificazione delle deficienze, selezione dei campioni) caricherà solo quella pertinente al task corrente.

Gli Slash Commands sono azioni esplicite — `/brief`, `/reconcile`, `/research`, `/audit-sample` — che attivano flussi di lavoro predefiniti quando invocati deliberatamente dall'utente. A differenza delle Skills che si attivano per pertinenza semantica, gli Slash Commands sono la primitiva corretta per operazioni ripetibili e critiche dove la prevedibilità del comportamento è più importante della flessibilità.

### Il pattern code-free

Una caratteristica distintiva del sistema Plugin è la completa assenza di necessità di competenze di programmazione per creare o modificare Plugin. I file Markdown si scrivono in qualsiasi editor di testo; il JSON del manifesto e della configurazione MCP segue pattern standard ben documentati. Questo abbassa drasticamente la barriera di adozione: un responsabile di processo aziendale può creare il Plugin per il proprio team senza coinvolgere il team IT, a patto di avere accesso alle credenziali dei servizi da connettere. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

### Playbook aziendali codificati come Skills

L'Anthropic Academy enfatizza una dimensione strategica del sistema Plugin che va oltre l'efficienza individuale: la codificazione della conoscenza tacita aziendale. La conoscenza procedurale dei dipendenti più esperti — come si gestisce una trattativa commerciale difficile, quali sono le eccezioni alle procedure standard, come si interpreta una clausola contrattuale ambigua — esiste tipicamente in forma implicita, trasmessa per osmosi. Convertirla in Skills Markdown la rende accessibile all'agente e quindi a tutti i membri del team che usano il Plugin. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

Questo trasforma il Plugin da strumento personale a infrastruttura di conoscenza organizzativa: il valore non si concentra nell'agente, ma nei file che lo guidano, che possono essere versionati, revisionati e distribuiti come qualsiasi altro documento.

## Esempi concreti

Un Plugin pre-configurato per l'internal audit può includere: Skills con le procedure di testing SOX 404 e la classificazione delle deficienze, un connettore MCP per il sistema ERP aziendale (in sola lettura), Slash Commands `/audit-sample` per la selezione automatica dei campioni di test e `/generate-memo` per la redazione della documentazione. Un auditor senza competenze tecniche può usare questo Plugin per eseguire test di conformità che prima richiedevano ore di lavoro manuale, con la garanzia che l'agente segue esattamente le procedure interne codificate nelle Skills. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

## Errori comuni e cosa evitare

Un errore comune è creare Plugin troppo generici con Skills che coprono domini ampi. Uno Skill file che descrive "tutte le procedure del team finance" è meno efficace di Skills separate per riconciliazione, report mensile, gestione fornitori. La granularità permette al meccanismo di pertinenza di selezionare esattamente la Skill giusta per ogni task, invece di caricare un documento lungo da cui il modello deve estrarre la parte rilevante. *(da Introduction to Claude Cowork — Intro to Claude Cowork)*

Un secondo errore è non versionare i file del Plugin. Poiché sono file Markdown e JSON, si prestano naturalmente al versionamento con Git: trattarli come documenti invece che come codice porta a perdere la traccia delle modifiche e a non poter tornare a versioni precedenti quando un aggiornamento degrada il comportamento dell'agente.

## Connessioni ad altri topic

Questo topic è la sintesi operativa di **Agent Skills in Claude Code** (le Skills come componente del Plugin), **Model Context Protocol: architettura** (i connettori MCP come componente del Plugin) e **Subagents e task delegation** (il Plugin come specifica di un worker specializzato). È anche collegato a **Compounding Context e memoria persistente in Cowork** (i file di contesto come complemento al Plugin per la personalizzazione dell'agente).