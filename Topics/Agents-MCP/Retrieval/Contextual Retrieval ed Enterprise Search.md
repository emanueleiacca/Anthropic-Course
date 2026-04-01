# Contextual Retrieval ed Enterprise Search

Aggiornato: April 1, 2026 2:05 PM
Categoria: Agents & MCP
Corsi: AI Fluency, Building with the Claude API, Claude 101
Stato: Completo

> 💬 Il Contextual Retrieval è un'evoluzione del RAG classico che risolve il problema della perdita di contesto nei chunk: aggiungendo una breve descrizione contestuale generata dal modello a ogni frammento prima dell'embedding, migliora drasticamente l'accuratezza del recupero su archivi documentali complessi.
> 

## Cos'è e perché importa

Il Retrieval-Augmented Generation (RAG) è diventato l'architettura standard per connettere i modelli linguistici a basi di conoscenza esterne. Tuttavia, nella pratica, le implementazioni RAG tradizionali soffrono di un problema fondamentale: quando un documento viene suddiviso in chunk per l'embedding, ogni frammento perde il contesto del documento originale. Una frase come "Il processo descritto nella sezione precedente richiede l'autorizzazione del manager" estratta dal documento perde il riferimento a quale processo, quale sezione, quale contesto organizzativo. Il recupero per similarità semantica funziona quindi su frammenti decontestualizzati, riducendo l'accuratezza proprio nei casi più complessi. *(da Claude 101 — Claude 101)*

## Spiegazione

### Il "conundrum del contesto" nei sistemi RAG

Il meccanismo del problema è semplice. Un documento di 100 pagine viene diviso in 500 chunk da circa 200 token ciascuno. Ogni chunk viene convertito in un vettore di embedding e indicizzato. Quando arriva una query, il sistema recupera i chunk con maggiore similarità vettoriale. Ma l'embedding di un chunk cattura il significato semantico locale del frammento, non la sua relazione con il documento originale o con altri frammenti. Il risultato è che query che richiedono di collegare informazioni distribuite — confronti, relazioni causa-effetto, dipendenze tra sezioni — vengono gestite in modo insoddisfacente. *(da Claude 101 — Claude 101)*

### La soluzione: contestualizzare i chunk prima dell'embedding

Il Contextual Retrieval risolve il problema aggiungendo un passo intermedio: prima di generare l'embedding di ogni chunk, si usa un modello più piccolo (Claude Haiku, per contenere i costi) per generare una breve descrizione contestuale (50-100 token) che colloca il frammento nel suo contesto originale. Questo testo contestuale viene anteposto al chunk prima dell'embedding, in modo che il vettore risultante catturi non solo il significato locale ma anche la posizione del frammento nel documento e le sue relazioni con le sezioni adiacenti. *(da Claude 101 — Claude 101)*

Il miglioramento dell'accuratezza è significativo in tre scenari: query che richiedono ragionamento su più sezioni di uno stesso documento, archivi con molti documenti simili dove la distinzione contestuale è critica, e query in linguaggio naturale che non matchano esattamente il vocabolario del documento.

### Hybrid Search: BM25 + semantica e reranking a due stadi

Il corso Building with the Claude API approfondisce la pipeline del Contextual Retrieval con la ricerca ibrida: la combinazione di ricerca semantica basata su embedding (che cattura la similarità concettuale) e ricerca lessicale BM25 (che cattura la presenza di parole chiave esatte, nomi propri, codici tecnici o sigle che l'embedding può non catturare adeguatamente). I risultati delle due ricerche vengono fusi con un algoritmo di rank fusion prima di passare alla fase successiva. *(da Building with the Claude API — Building with the Claude API)*

Il reranking aggiunge un secondo stadio: dai primi 150 risultati combinati, un modello di reranking specializzato valuta la pertinenza rispetto alla query originale e seleziona i migliori 20 da passare a Claude. I 150 risultati iniziali garantiscono ampia copertura (recall elevata), il reranking garantisce che solo le informazioni più pertinenti entrino nel contesto (precisione elevata). Questo doppio filtraggio ha prodotto la riduzione del 67% nel tasso di fallimento riportata da Anthropic.

### Enterprise Search in Claude

Nell'ecosistema Claude, l'Enterprise Search permette di applicare questa potenza di ricerca ai dati interni aziendali: Notion, SharePoint, Slack, GitHub, sistemi di ticketing. La sfida enterprise non è solo tecnica ma anche organizzativa: i documenti interni spesso usano terminologia aziendale specifica, acronimi e riferimenti impliciti che un sistema di embedding generico non cattura bene. Il Contextual Retrieval mitiga parzialmente questo problema contestualizzando ogni chunk nel suo ambiente documentale. *(da Claude 101 — Claude 101)*

### La modalità Research come investigatore sistematico

La modalità Research di Claude è una manifestazione ad alto livello di questi principi: invece di rispondere direttamente a una domanda complessa, il modello scompone la query in sotto-domande, pianifica una strategia di ricerca multi-step, legge articoli completi invece di limitarsi agli snippet, incrocia le fonti per verificare la coerenza, e produce un report strutturato con citazioni precise. *(da Claude 101 — Claude 101)*

## Esempi concreti

In un'implementazione pratica su una knowledge base aziendale, il pre-processing di ogni documento prima dell'indicizzazione include: chunking del documento, generazione del contesto via Haiku per ogni chunk ("Questo passaggio fa parte della sezione sulle procedure di escalation del documento Policy_IT_2024; descrive i criteri per l'escalation di Livello 2..."), concatenazione contesto + chunk, generazione dell'embedding sul testo arricchito. Il costo aggiuntivo del pre-processing è ammortizzato sulla vita dell'indice, che rimane aggiornato finché i documenti non cambiano. *(da Claude 101 — Claude 101)*

## Errori comuni e cosa evitare

Un errore comune è usare chunk troppo grandi pensando che più contesto per chunk significhi meno perdita di informazione. In realtà, chunk troppo grandi producono embedding meno precisi semanticamente e riducono la granularità del recupero. Il range ottimale è tipicamente 200-400 token per chunk, con overlap tra chunk adiacenti per non spezzare concetti che si estendono su più frammenti. *(da Claude 101 — Claude 101)*

## Connessioni ad altri topic

Questo topic si connette a **Memory e stato negli agenti** (il RAG come forma di memoria esternalizzata), a **Model Context Protocol: architettura** (MCP come infrastruttura per connettere Claude agli archivi documentali enterprise), a **Modelli Claude: famiglie e differenze** (l'uso di Haiku per la generazione dei contesti nei sistemi RAG ad alto volume) e a **Batch API** (il pre-processing dei chunk può beneficiare della Batch API per archivi di grandi dimensioni).