# Evaluation-driven development (Evals)

Aggiornato: April 1, 2026 2:20 PM
Categoria: API & Tools
Corsi: Building with the Claude API, Intro to Agent Skills
Stato: Completo

Fonte: Building with the Claude API — Building with the Claude API

> 💬 L'Evaluation-driven development è l'approccio metodologico con cui si misura e migliora sistematicamente la qualità delle risposte di Claude: senza pipeline di valutazione rigorose non è possibile sapere se un cambiamento al prompt migliora o peggiora il sistema, e non è possibile prevenire regressioni.
> 

## Cos'è e perché importa

Nel momento in cui un sistema basato su Claude va in produzione, il prompting smette di essere un'attività intuitiva e diventa ingegneria dei sistemi. Ogni modifica al prompt, ogni aggiornamento del modello, ogni espansione delle funzionalità introduce il rischio di regressioni: comportamenti che funzionavano correttamente iniziano a produrre output peggiori, spesso in modo non ovvio. Senza un framework di valutazione sistematico, questi problemi vengono scoperti dagli utenti in produzione invece che durante lo sviluppo. *(da Building with the Claude API — Building with the Claude API)*

Il principio fondante dell'approccio è semplice ma radicale: non è possibile migliorare ciò che non si misura. Costruire pipeline di valutazione prima di ottimizzare i prompt — invece che dopo — è la differenza tra uno sviluppo sistematico e uno sviluppo guidato dall'intuizione.

## Spiegazione

### Generazione del dataset di test

Il primo passo è costruire un dataset di casi di test che copra adeguatamente lo spazio di input del sistema. Il corso Building with the Claude API raccomanda di usare modelli più potenti — tipicamente Claude Opus — per generare casi di test realistici e, soprattutto, edge cases che sarebbero difficili da identificare manualmente. *(da Building with the Claude API — Building with the Claude API)*

Questo approccio ha un vantaggio importante rispetto alla costruzione manuale del dataset: Opus è in grado di generare varianti plausibili dell'input che coprono le zone di confine del comportamento del sistema — input ambigui, parzialmente malformati, con informazioni mancanti, con istruzioni in conflitto. Questi sono esattamente i casi in cui i sistemi falliscono in modo inatteso in produzione, e averli nel dataset prima del rilascio permette di rilevarli durante lo sviluppo.

### Grading basato su modello giudice

Per output che non hanno una risposta univocamente corretta — testo generato, analisi, risposte a domande aperte — la valutazione richiede un modello "giudice" che valuti la qualità delle risposte prodotte dal modello in test. Il giudice riceve sia l'input originale sia la risposta del modello e assegna un punteggio basato su criteri definiti dallo sviluppatore. *(da Building with the Claude API — Building with the Claude API)*

I criteri di valutazione devono essere specifici e operazionalizzati in linguaggio naturale: non "la risposta è buona" ma "la risposta rispetta il tono professionale specificato nel system prompt", "la risposta include tutti gli elementi richiesti dalla specifica", "la risposta non contiene affermazioni non supportate dal contesto fornito". Criteri vaghi producono grading incoerente che non permette di misurare miglioramenti reali.

L'uso di un modello come giudice ha anche un limite importante: il giudice può avere bias sistematici, ad esempio preferire risposte più lunghe o risposte che usano lo stesso stile del modello giudice. Questo va compensato calibrando i criteri e verificando periodicamente la coerenza del grading su un campione di esempi valutati anche manualmente.

### Grading deterministico per output strutturati

Per output che hanno una struttura definita — JSON, codice, liste di elementi, classificazioni — il grading basato su modello è inutilmente costoso e lento. Script deterministici verificano la correttezza dello schema (il JSON è valido? Ha tutti i campi richiesti?), dei valori critici (le classificazioni sono tra quelle previste? I calcoli sono corretti?) e delle proprietà strutturali (il codice è sintatticamente valido? Supera i test unitari?). *(da Building with the Claude API — Building with the Claude API)*

Questo tipo di grading è il più affidabile perché è completamente deterministico: lo stesso input produce sempre lo stesso punteggio, permettendo confronti precisi tra versioni diverse del prompt o del modello.

### Skill Creator: il ciclo iterativo di Anthropic per le Skills

Il corso Intro to Agent Skills introduce lo Skill Creator come strumento specifico di Anthropic per guidare il ciclo di sviluppo di una Skill secondo il paradigma Evaluation-Driven. Lo strumento accompagna lo sviluppatore attraverso quattro fasi sequenziali. *(da Introduction to Agent Skills — Intro to Agent Skills)*

La prima fase è l'identificazione dei gap: si eseguono i task rappresentativi senza la Skill e si documentano i punti di fallimento. La seconda fase è la creazione degli Evals: almeno tre scenari di test con variazioni nel modo in cui l'utente potrebbe formulare la richiesta, includendo parafrasature diverse dello stesso intento. La terza fase è il test comparativo parallelo: per ogni caso si lanciano due subagent simultaneamente, uno con la Skill e uno baseline senza, confrontando i risultati su metriche oggettive (successo del task, numero di turni, token totali). La quarta fase è l'iterazione sulla descrizione e il contenuto della Skill fino a quando le metriche mostrano un miglioramento misurabile. Questo approccio garantisce che ogni Skill aggiunta porti un valore dimostrabile.

### Il ciclo di eval come pratica continua

L'Evaluation-driven development non è un'attività che si fa una volta prima del rilascio: è una pratica continua integrata nel processo di sviluppo. Ogni modifica significativa al prompt va valutata contro il dataset di riferimento prima di essere rilasciata. Ogni aggiornamento del modello (cambio di versione, migrazione a un nuovo tier) va testato sistematicamente. Il dataset di test cresce nel tempo aggiungendo i casi che hanno prodotto fallimenti in produzione, rendendo la pipeline progressivamente più robusta. *(da Building with the Claude API — Building with the Claude API)*

## Esempi concreti

Una pipeline di eval per un sistema di classificazione del sentiment:

```python
# 1. Genera dataset con Opus
test_cases = generate_test_cases_with_opus(
    task="classificazione sentiment",
    n_cases=100,
    include_edge_cases=True
)

# 2. Esegui il modello in test su ogni caso
results = []
for case in test_cases:
    response = claude_classify(case["input"])
    results.append({
        "input": case["input"],
        "expected": case["expected"],
        "actual": response,
        "correct": response == case["expected"]
    })

# 3. Calcola le metriche
accuracy = sum(r["correct"] for r in results) / len(results)
print(f"Accuracy: {accuracy:.2%}")

# 4. Analizza i fallimenti
failures = [r for r in results if not r["correct"]]
# Usa questi casi per identificare dove migliorare il prompt
```

*(da Building with the Claude API — Building with the Claude API)*

## Errori comuni e cosa evitare

L'errore più comune è costruire il dataset di test a partire dagli stessi esempi usati per sviluppare il prompt. Questo produce valutazioni falsamente ottimistiche: il sistema performa bene sui casi che già conosce e fallisce su quelli nuovi. Il dataset di eval deve essere costruito indipendentemente dal processo di sviluppo del prompt, idealmente includendo casi che il prompt non ha mai "visto". *(da Building with the Claude API — Building with the Claude API)*

Un secondo errore è usare criteri di grading troppo vaghi per il modello giudice. Se il giudice non ha istruzioni precise su cosa valutare e come, i punteggi assegnati riflettono preferenze generiche del modello giudice invece che i criteri specifici del sistema sotto test. I criteri devono essere scritti con la stessa cura dei prompt di produzione.

## Connessioni ad altri topic

Questo topic è il fondamento metodologico che rende affidabile qualsiasi sistema basato su Claude. È collegato a **Few-shot prompting** (gli esempi nel dataset come casi di test oltre che come guida), a **Gestione del ciclo di vita dei modelli** (le eval come strumento di verifica durante le migrazioni di modello), e a **Pattern di workflow agentici** (dove la valutazione sistematica è particolarmente critica per sistemi complessi con più componenti).