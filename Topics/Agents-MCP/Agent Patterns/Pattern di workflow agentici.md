# Pattern di workflow agentici

Aggiornato: March 31, 2026 7:08 PM
Categoria: Agents & MCP
Corsi: Building with the Claude API
Stato: Completo

Fonte: Building with the Claude API — Building with the Claude API

> 💬 I cinque pattern fondamentali di workflow agentico — Prompt Chaining, Routing, Parallelization, Orchestrator-Workers, Evaluator-Optimizer — sono il catalogo architetturale con cui si progettano sistemi AI complessi: ciascuno ha scenari d'uso distinti e trade-off precisi tra autonomia, affidabilità e complessità implementativa.
> 

## Cos'è e perché importa

Un singolo prompt è sufficiente per task semplici e ben delimitati. Ma la maggior parte dei problemi reali è troppo complessa, troppo lunga o troppo multidimensionale per essere risolta in un'unica interazione. La scelta del pattern architetturale giusto è una decisione di ingegneria con conseguenze significative sull'affidabilità, sul costo e sulla manutenibilità del sistema. Il corso Building with the Claude API sistematizza questa scelta in cinque pattern fondamentali, ciascuno ottimizzato per una classe specifica di problemi. *(da Building with the Claude API — Building with the Claude API)*

Una distinzione importante che il corso introduce è quella tra workflow deterministici e agenti autonomi. I workflow deterministici seguono un percorso predefinito con punti di decisione controllati; gli agenti autonomi decidono autonomamente il percorso in base all'input e ai risultati intermedi. Per task aziendali critici, i workflow deterministici sono spesso preferibili nonostante la loro minore flessibilità, perché il loro comportamento è prevedibile e testabile in modo molto più affidabile.

## Spiegazione

### Pattern 1: Prompt Chaining

Il Prompt Chaining è il pattern più semplice e più controllabile: una sequenza di prompt dove l'output del passaggio precedente diventa l'input del successivo. Ogni step del chain ha un obiettivo ben definito e limitato, e la complessità complessiva del task emerge dalla composizione di passi semplici. *(da Building with the Claude API — Building with the Claude API)*

Lo scenario d'uso tipico è la generazione di contenuti in più fasi: ricerca di informazioni sul tema → selezione degli argomenti più rilevanti → scrittura della bozza → revisione e raffinamento → formattazione finale. Ogni step può usare un prompt diverso, un modello diverso (Haiku per la classificazione, Sonnet per la scrittura) e può avere logica di validazione specifica. Il vantaggio principale è la debuggabilità: quando qualcosa va storto, si identifica immediatamente in quale step del chain si è verificato il problema.

### Pattern 2: Routing

Il Routing introduce un classificatore iniziale che analizza la richiesta e la smista verso diversi sub-workflow o agenti specializzati, ciascuno ottimizzato per una categoria specifica di input. Il classificatore può essere implementato con Claude (usando un prompt di classificazione) o con un classificatore tradizionale più economico. *(da Building with the Claude API — Building with the Claude API)*

Lo scenario d'uso emblematico è il customer support multi-dominio: le richieste vengono classificate per tipo (problema tecnico, domanda di fatturazione, richiesta commerciale) e instradate verso agenti con prompt di sistema ottimizzati per ciascun dominio. Il vantaggio è che ogni agente può essere ottimizzato e testato indipendentemente, e il sistema nel complesso è più preciso di un singolo agente generalista che deve coprire tutti i domini.

### Pattern 3: Parallelization

La Parallelization esegue più task indipendenti contemporaneamente e aggrega i risultati alla fine. È il pattern corretto quando il problema si può decomporre in sotto-problemi indipendenti e il tempo di risposta è un vincolo critico. *(da Building with the Claude API — Building with the Claude API)*

Lo scenario tipico è l'analisi competitiva: invece di analizzare cinque competitor in sequenza, si lanciano cinque istanze in parallelo, ciascuna focalizzata su un competitor, e si aggrega il risultato in un report comparativo. Il tempo totale è quello del task più lento invece della somma di tutti i task. Un altro caso comune è il voting: lanciare lo stesso prompt più volte in parallelo e aggregare i risultati con majority voting per aumentare la robustezza su task dove la risposta corretta non è sempre deterministica.

### Pattern 4: Orchestrator-Workers

Nel pattern Orchestrator-Workers, un agente centrale (orchestratore) riceve l'obiettivo di alto livello, pianifica la strategia, decompone il task in sotto-task e li delega ad agenti lavoratori specializzati. L'orchestratore non esegue direttamente il lavoro: coordina, monitora i risultati e decide il passo successivo in base a ciò che i worker restituiscono. *(da Building with the Claude API — Building with the Claude API)*

Questa è l'architettura corretta per task complessi e aperti dove non è possibile predefinire il percorso esatto: sviluppo software su più file, analisi di dati multidimensionale, ricerca su più fonti. L'orchestratore può decidere dinamicamente di lanciare un worker aggiuntivo se i risultati parziali suggeriscono la necessità di ulteriori indagini. Questo lo rende più flessibile del Chaining (dove il percorso è fisso) e più controllabile di un singolo agente autonomo (dove tutto avviene in un'unica sessione monolitica).

### Pattern 5: Evaluator-Optimizer

L'Evaluator-Optimizer è un loop iterativo dove un modello genera un output e un secondo modello lo critica e suggerisce miglioramenti, che vengono applicati nella iterazione successiva. Il loop continua fino a quando il valutatore ritiene l'output soddisfacente o fino al raggiungimento di un numero massimo di iterazioni. *(da Building with the Claude API — Building with the Claude API)*

Lo scenario d'uso è la produzione di contenuti ad alta qualità dove il primo tentativo raramente è sufficiente: scrittura di codice critico (genera → testa → correggi in base ai test falliti → ritesta), traduzioni letterarie di alta qualità (traduci → critica la traduzione → migliora → rivaluta), o ottimizzazione di prompt (genera variante → valuta contro il dataset → identifica debolezze → genera variante migliorata). Il rischio principale è il loop infinito: il sistema deve sempre avere una condizione di uscita che non dipende solo dalla qualità dell'output.

## Esempi concreti

Un esempio di Evaluator-Optimizer applicato alla generazione di codice:

```python
max_iterations = 3
for i in range(max_iterations):
    # Genera o migliora il codice
    code = generate_code(requirements, previous_feedback)
    
    # Esegui i test
    test_results = run_tests(code)
    
    if test_results.all_passed:
        break  # Condizione di uscita esplicita
    
    # Prepara il feedback per la prossima iterazione
    previous_feedback = format_test_failures(test_results)

return code
```

La condizione di uscita esplicita (`max_iterations`) è obbligatoria: un loop che termina solo quando tutti i test passano può iterare indefinitamente su un bug che il modello non riesce a correggere. *(da Building with the Claude API — Building with the Claude API)*

## Errori comuni e cosa evitare

L'errore più comune è scegliere il pattern più sofisticato per impostazione predefinita. L'Orchestrator-Workers è potente ma costoso, lento e difficile da debuggare rispetto al Prompt Chaining. La regola generale è usare il pattern più semplice che soddisfa i requisiti del task: aggiungere complessità architetturale solo quando è giustificata da esigenze concrete. *(da Building with the Claude API — Building with the Claude API)*

Un secondo errore è non prevedere condizioni di uscita esplicite in tutti i pattern iterativi (Evaluator-Optimizer, qualsiasi loop agentico). Un sistema che può iterare all'infinito è un sistema che inevitabilmente lo farà, consumando token e budget senza produrre risultati.

## Connessioni ad altri topic

Questo topic è il catalogo architetturale che integra tutto l'area Agents & MCP. È collegato a **Agentic loop e autonomia** (il loop agentico come meccanismo sottostante di ogni pattern), a **Subagents e task delegation** (il pattern Orchestrator-Workers in dettaglio), a **Tool Use (Function Calling)** (il tool use come meccanismo di esecuzione all'interno dei pattern) e a **Evaluation-driven development** (le eval come strumento di validazione della qualità del sistema che usa questi pattern).