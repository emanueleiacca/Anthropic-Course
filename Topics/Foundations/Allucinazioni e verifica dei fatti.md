# Allucinazioni e verifica dei fatti

Aggiornato: March 31, 2026 2:19 PM
Categoria: Foundations
Corsi: AI Fluency
Stato: Bozza

Fonte: AI Fluency — AI Fluency

> 💬 Le allucinazioni sono informazioni false presentate dal modello con tono assertivo: riconoscerle, mitigarle e gestirle sistematicamente è una competenza centrale dell'AI Fluency, non un problema che il modello risolve autonomamente.
> 

## Cos'è e perché importa

I modelli linguistici generano testo che suona plausibile e spesso è accurato, ma in alcuni casi producono affermazioni false, citazioni inesistenti, date sbagliate o riferimenti a fonti che non esistono — il tutto con lo stesso tono assertivo usato per le informazioni corrette. Questo fenomeno, chiamato "allucinazione", è una delle sfide più importanti nell'uso professionale dell'AI. Non si tratta di malfunzionamenti isolati: è una caratteristica strutturale dei modelli linguistici che emerge dalla loro natura probabilistica. Un utente fluente non si chiede "questo modello allucina?", ma "come gestisco sistematicamente le allucinazioni in questo workflow?". *(da AI Fluency — AI Fluency)*

## Spiegazione

### Perché i modelli allucinano

I modelli linguistici non "sanno" cose nel senso in cui le sa un database: producono sequenze di token probabilisticamente plausibili in base ai pattern del training. Quando viene chiesto qualcosa su cui il modello ha poche informazioni di training, o qualcosa che richiede conoscenze recenti o molto specifiche, il modello può produrre testo che è plausibile nel formato ma errato nel contenuto. Il problema è amplificato dal fatto che il modello raramente segnala spontaneamente la propria incertezza: risponde con lo stesso livello di confidenza apparente sia quando conosce bene l'argomento sia quando sta "interpolando" su informazioni incomplete. *(da AI Fluency — AI Fluency)*

### Tecnica 1: richiesta di citazioni

Il primo strumento di mitigazione è richiedere esplicitamente le fonti per ogni affermazione rilevante. Inserire nel prompt "cita le fonti per ogni dato quantitativo" o "includi i riferimenti alle pubblicazioni originali" ha due effetti. Il primo effetto è diagnostico: se il modello non riesce a citare fonti specifiche o cita fonti vaghe, è un segnale che l'affermazione potrebbe non essere verificabile. Il secondo effetto è preventivo: il requisito esplicito di citare riduce la tendenza del modello a inventare dati non supportati. *(da AI Fluency — AI Fluency)*

Attenzione: le citazioni fornite dal modello devono sempre essere verificate esternamente. Il modello può anche inventare citazioni plausibili ma inesistenti.

### Tecnica 2: verifica incrociata

Per affermazioni critiche, la strategia più robusta è la verifica incrociata su fonti esterne indipendenti. Questo significa non usare il modello come unica fonte di verità per informazioni fattuali rilevanti, ma trattarne l'output come una prima bozza da validare. In contesti professionali ad alto rischio — analisi legale, dati medici, rendicontazione finanziaria — questa verifica non è opzionale. *(da AI Fluency — AI Fluency)*

### Tecnica 3: chiedere al modello di identificare le proprie lacune

Una tecnica avanzata descritta nel corso AI Fluency consiste nel chiedere al modello di identificare attivamente i propri punti deboli sull'argomento trattato: "Quali aspetti di questa risposta potrebbero essere incompleti o imprecisi? Dove ti mancano informazioni sufficienti per essere certo?". Questo comportamento — chiamato "identificare il contesto mancante" nell'AI Fluency Index — è uno degli indicatori chiave di fluenza professionale. *(da AI Fluency — AI Fluency)*

Il meccanismo funziona perché il modello, quando esplicitamente interrogato sulla propria incertezza, tende a segnalarla con maggiore precisione rispetto a quando deve produrre un output assertivo. La domanda meta-cognitiva cambia il frame della risposta da "genera informazioni" a "valuta la tua confidenza".

### Tecnica 4: Reasoning Audit per i modelli con Extended Thinking

Con i modelli che supportano Extended Thinking nativo (Claude 3.7+), la verifica può spostarsi dall'output al processo. I blocchi di pensiero intermedio del modello sono ispezionabili: verificare se il percorso logico che ha portato a un'affermazione è coerente e privo di errori permette di intercettare problemi prima che si riflettano nel risultato finale. Un'affermazione può suonare corretta pur derivando da un'inferenza errata nel ragionamento intermedio — il Reasoning Audit la individua prima che venga pubblicata. *(da AI Fluency — AI Fluency)*

### Zone di rischio elevato

Alcune categorie di task hanno un rischio di allucinazione strutturalmente più alto di altre: dati quantitativi precisi (statistiche, percentuali, date), citazioni di testi specifici, descrizioni di ricerche accademiche recenti, informazioni su eventi dopo la data di cutoff del training, e contenuti molto specifici su nicchie poco rappresentate nei dati di training. Identificare queste zone di rischio nel proprio workflow e applicare sistematicamente le tecniche di verifica è l'approccio più pragmatico. *(da AI Fluency — AI Fluency)*

## Esempi concreti

Un analista che chiede a Claude di preparare un report di mercato con dati quantitativi applica sistematicamente: nel prompt richiede esplicitamente che ogni dato sia accompagnato dalla fonte; quando riceve l'output, verifica un campione di citazioni su fonti primarie; per le affermazioni più critiche per la tesi del report, chiede al modello "quali di questi dati sei meno sicuro di citare con precisione?". Questo workflow non elimina il rischio di allucinazione ma lo porta a un livello accettabile per uso professionale. *(da AI Fluency — AI Fluency)*

## Errori comuni e cosa evitare

L'errore più pericoloso è assumere che la confidenza del tono sia proporzionale all'accuratezza del contenuto. Il modello usa lo stesso registro assertivo per citare la data della battaglia di Waterloo e per inventare una statistica che non esiste. Il secondo errore è pensare che i modelli più recenti abbiano eliminato il problema: le allucinazioni si sono ridotte con i modelli più capaci, ma non sono scomparse — e la riduzione può paradossalmente aumentare il rischio se porta l'utente ad abbassare la guardia. *(da AI Fluency — AI Fluency)*

## Connessioni ad altri topic

Questo topic è collegato a **Framework 4D e AI Fluency** (il Discernment come pilastro metodologico per la verifica), a **Chain-of-thought e ragionamento esplicito** (il Reasoning Audit come estensione del CoT alla verifica delle allucinazioni), e a **Responsible use e bias** (le implicazioni etiche di pubblicare contenuto non verificato).