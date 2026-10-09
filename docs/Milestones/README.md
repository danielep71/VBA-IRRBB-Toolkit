# 🗺️ Milestones — dalla foundation alla v1.0.0

Queste guide spiegano in italiano **che cosa deve consegnare ogni milestone,
perché serve e quali evidenze consentono di considerarla completata**.
I titoli inglesi corrispondono alle milestone GitHub. La roadmap di riferimento
è quella approvata il 9 ottobre 2026 e registrata nel
[foundation closeout](../FOUNDATION_CLOSEOUT.md).

## 🧭 Percorso e risultati attesi

| Milestone | Domanda a cui risponde | Consegna principale |
| --- | --- | --- |
| [🏗️ v0.1.0](v0.1.0.md) | Su quali regole costruiamo? | Architettura, contratti di base, controlli e governance |
| [📊 v0.2.0](v0.2.0.md) | Come rendiamo operativi workbook, dati e test? | Applicazione Excel di base riproducibile e importazione controllata |
| [📉 v0.3.0](v0.3.0.md) | Come descriviamo il deflusso del saldo aggregato? | Motore Decay verificato con riferimenti indipendenti |
| [📈 v0.4.0](v0.4.0.md) | Come reagiscono i tassi cliente ai tassi di mercato? | Modello Rates con stima, diagnostica e simulazione |
| [🏦 v0.5.0](v0.5.0.md) | Quanto dei saldi esistenti permane nel tempo? | Modello Stable e aggregazione coerente delle coorti |
| [🔗 v0.6.0](v0.6.0.md) | Come lavorano insieme i modelli? | Calibrazione e backtesting integrati e riproducibili |
| [⚖️ v0.7.0](v0.7.0.md) | Come applichiamo scenari e vincoli pertinenti? | Scenari coerenti e vincoli tracciabili alle fonti |
| [🖥️ v0.8.0](v0.8.0.md) | Come usa ed esporta i risultati un utente? | Percorso operativo, persistenza ed esportazione ALM |
| [🧪 v0.9.0](v0.9.0.md) | L'intera applicazione è pronta al rilascio? | Candidato congelato e qualificato con evidenze complete |
| [🚀 v1.0.0](v1.0.0.md) | Quale prodotto accettiamo e rilasciamo? | Prima applicazione NMD stabile, nei limiti dichiarati |

## 📖 Come leggere le guide

Ogni file contiene scopo, motivazione, attività e risultati osservabili,
dipendenze, esempio sintetico, criteri di completamento e collegamenti.
Le attività sono una scomposizione operativa dello scopo approvato: non sono
una certificazione di funzionalità già disponibili. I criteri elencati non
costituiscono un registro di test eseguiti.

Le issue GitHub conservano stato corrente, assegnazione, priorità e prove di
chiusura. Le guide non duplicano percentuali o contatori destinati a diventare
obsoleti. La sezione di tracciamento in ogni file identifica le issue note al
9 ottobre 2026 e gli eventuali pacchetti ancora da dettagliare.

## 🔗 Dipendenze: ordine di consegna e prerequisiti

La v0.2.0 fornisce dati, host e test ai tre modelli. La numerazione colloca
Decay prima di Rates e Stable, ma non introduce una dipendenza matematica di
Rates dalla formula Decay. La v0.6.0 richiede i tre modelli e un contratto
esplicito per la loro composizione. La v0.7.0 aggiunge gli scenari coordinati
e i vincoli applicabili; la v0.8.0 completa il percorso utente. La v0.9.0
riunisce le evidenze prima dell'accettazione della v1.0.0.

Le correzioni metodologiche [#32–#37](../methodology/MODEL_CONTRACTS.md)
precedono le implementazioni interessate. L'issue ombrello
[#26](https://github.com/danielep71/VBA-IRRBB-Toolkit/issues/26), assegnata
alla v0.7.0, non rinvia a quella versione i prerequisiti dei modelli precedenti.

## 🧪 Regole comuni di completamento

- **Dati sintetici e provenienza:** esempi e prove nel repository devono essere
  riproducibili e privi di dati reali riservati.
- **Riferimenti indipendenti:** i valori attesi non provengono dal modello che
  si sta verificando; fonti, versioni, semi e tolleranze sono registrati.
- **Evidenza Excel:** quando si introduce VBA, compilazione, test e scenari
  devono essere eseguiti sull'host concordato e associati all'esatto commit.
  CI statica e LibreOffice non sostituiscono queste prove.
- **Errori e risultati:** un errore non produce un PASS; risultati precedenti,
  incompleti o relativi a input cambiati non devono apparire correnti. Errore
  principale ed eventuale errore di ripristino restano entrambi visibili.
- **Chiusura e pubblicazione:** chiudere una milestone non autorizza da solo
  integrazione in main, tag, release, distribuzione o cambio di visibilità.
  Si segue [RELEASING.md](../../RELEASING.md) con le decisioni del proprietario.

## 📚 Documenti che governano le decisioni

Queste guide spiegano la roadmap; non modificano equazioni, soglie, API o
decisioni di supporto. In caso di discrepanza, registrare il punto in un'issue
e aggiornare insieme guida e contratto tramite PR.

| Argomento | Riferimento |
| --- | --- |
| Architettura e confini del codice | [Repository structure](../REPOSITORY_STRUCTURE.md) |
| Dati e regole temporali | [Data contract](../methodology/DATA_CONTRACT.md) |
| Specifiche e prerequisiti dei modelli | [Model contracts](../methodology/MODEL_CONTRACTS.md) |
| Fonti e loro stato di verifica | [Sources](../methodology/SOURCES.md) |
| Casi numerici e validazione | [Test cases](../methodology/TEST_CASES.md), [Validation plan](../methodology/VALIDATION_PLAN.md) |
| Evidenze sull'host Excel | [Excel evidence](../EXCEL_EVIDENCE.md) |
| Workflow e chiusura delle issue | [Governance](../GOVERNANCE.md), [Contributing](../../CONTRIBUTING.md) |

Il perimetro della v1.0.0 è l'applicazione comportamentale per i depositi
senza scadenza contrattuale (NMD). Un motore EVE/NII dell'intero banking book
o un'integrazione specifica con un fornitore richiedono un perimetro approvato
separatamente. Non sono fissate date di consegna da queste guide.
