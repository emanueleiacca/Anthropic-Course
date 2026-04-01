# Setup e installazione di Claude Code

Aggiornato: April 1, 2026 2:12 PM
Categoria: Claude Code
Corsi: Claude Code in Action
Stato: Completo

Fonte: Claude Code in Action — Claude Code in Action

> 💬 L'installazione di Claude Code richiede attenzione alle specificità di ogni piattaforma: il metodo scelto determina la gestione degli aggiornamenti automatici, i permessi corretti e l'integrazione con le credenziali dell'account.
> 

## Cos'è e perché importa

Claude Code è distribuito come strumento CLI multi-piattaforma, e la scelta del metodo di installazione ha conseguenze operative non ovvie. Un'installazione errata può causare errori di permessi durante l'esecuzione dei tool secondari, impedire gli aggiornamenti automatici, o produrre comportamenti inattesi in certi ambienti. Conoscere le differenze tra i metodi disponibili permette di scegliere quello corretto per il proprio contesto e di diagnosticare i problemi quando emergono. *(da Claude Code in Action — Claude Code in Action)*

## Spiegazione

### Metodi di installazione per piattaforma

Anthropic privilegia i binari nativi con aggiornamenti automatici in background rispetto ai package manager di terze parti che richiedono aggiornamenti manuali. La scelta del metodo ha implicazioni sulla frequenza con cui si dispone dell'ultima versione. *(da Claude Code in Action — Claude Code in Action)*

Su macOS, Linux e WSL il metodo raccomandato è lo script shell ufficiale, che installa il binario nativo e configura gli aggiornamenti automatici in background:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

Su Windows PowerShell il comando equivalente è `irm https://claude.ai/install.ps1 | iex`, da eseguire in un terminale standard e non come amministratore. Su Windows CMD la procedura è leggermente più articolata e richiede la presenza di Git for Windows.

L'installazione tramite Homebrew (`brew install --cask claude-code`) è comoda ma non si aggiorna automaticamente: richiede `brew upgrade claude-code` periodico, il che può portare a usare versioni obsolete senza accorgersene in periodi di rilasci frequenti. Lo stesso vale per WinGet (`winget install Anthropic.ClaudeCode`), che richiede `winget upgrade` manuale.

### L'anti-pattern di sudo npm install -g

L'uso di `sudo npm install -g @anthropic-ai/claude-code` è esplicitamente sconsigliato, nonostante possa sembrare il modo più semplice per chi è abituato all'ecosistema npm. Il problema è che installare pacchetti globali con sudo può generare errori di permessi quando Claude Code cerca di eseguire tool secondari che richiedono accesso al filesystem dell'utente. L'installazione sembra andare a buon fine, ma i problemi emergono durante l'uso operativo in scenari non banali. *(da Claude Code in Action — Claude Code in Action)*

### Gestione delle credenziali e workspace

L'autenticazione avviene tramite diversi canali. Gli abbonamenti consumer (Pro, Max) si autenticano tramite browser OAuth. I team e le organizzazioni possono usare credenziali API pay-as-you-go della Anthropic Console: al primo accesso viene creato automaticamente un workspace dedicato denominato "Claude Code", che permette ai team leader di monitorare i costi e l'utilizzo separatamente rispetto ad altri progetti API. *(da Claude Code in Action — Claude Code in Action)*

Per infrastrutture enterprise, è supportata l'integrazione con provider cloud come Amazon Bedrock e Google Vertex AI, che permette di far girare Claude Code attraverso l'infrastruttura cloud aziendale invece di chiamare direttamente l'API Anthropic.

### Il comando diagnostico claude doctor

Dopo l'installazione, il comando `claude doctor` esegue una diagnosi completa del sistema: verifica le dipendenze installate (come `git` e `ripgrep`), controlla la configurazione dell'autenticazione e testa la connessione di rete all'API. È il primo strumento da usare quando Claude Code non si comporta come atteso: la maggior parte dei problemi di avvio è dovuta a dipendenze mancanti o configurazione di rete non corretta, non a bug del software. *(da Claude Code in Action — Claude Code in Action)*

## Esempi concreti

Un'installazione tipica su macOS con verifica:

```bash
# Installazione
curl -fsSL https://claude.ai/install.sh | bash

# Verifica post-installazione
claude doctor

# Output atteso:
# ✓ Claude Code: v1.x.x
# ✓ git: installato
# ✓ ripgrep: installato  
# ✓ Connessione API: OK
# ✓ Autenticazione: configurata
```

*(da Claude Code in Action — Claude Code in Action)*

## Errori comuni e cosa evitare

Oltre all'anti-pattern `sudo npm install -g` già descritto, un errore comune è non eseguire `claude doctor` dopo un aggiornamento del sistema operativo o dopo aver cambiato la versione di Node.js. Le dipendenze possono rompersi silenziosamente, causando comportamenti anomali che non producono errori espliciti ma degradano la qualità delle risposte. *(da Claude Code in Action — Claude Code in Action)*

Un secondo errore frequente in ambienti team è condividere la stessa chiave API tra tutti i membri invece di creare credenziali separate per utente. Il workspace dedicato "Claude Code" nella Console di Anthropic è progettato proprio per monitorare l'utilizzo per utente: condividere una singola chiave elimina questa visibilità e rende impossibile identificare chi sta consumando quota o generando errori.

## Connessioni ad altri topic

Questo topic è il prerequisito operativo per tutta l'area Claude Code. È collegato a **Architettura di Claude Code** (il sistema che si sta installando), a **Context management nel codice** (le configurazioni successive all'installazione) e a **Sicurezza avanzata in Claude Code** (le impostazioni di sicurezza da configurare dopo l'installazione).