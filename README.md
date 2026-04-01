# 📚 Anthropic Academy Knowledge Base

A topic-first Markdown knowledge base for studying Anthropic, Claude, agent systems, MCP, prompting, API workflows, and Claude Code.

## Overview

This repository is a structured learning workspace built from exported notes and reorganized into a clear hierarchy.

It exists to make exploration easier than a flat note dump:
- browse by **concept** in [`Topics/`](Topics/index.md)
- browse by **course lineage** in [`Courses/`](Courses/index.md)
- keep the original database exports in [`Data/`](Data/index.md)

It is best suited for:
- self-study
- concept review
- building mental models across related topics
- navigating notes in a documentation-style format

## 🚀 Quick Links

- [Start Here](#-start-here)
- [Topics](Topics/index.md)
- [Courses](Courses/index.md)
- [Data](Data/index.md)

### Main Topic Areas
- [Foundations](Topics/Foundations/index.md)
- [Prompting](Topics/Prompting/index.md)
- [API-Tools](Topics/API-Tools/index.md)
- [Agents-MCP](Topics/Agents-MCP/index.md)
- [Claude Code](Topics/Claude%20Code/index.md)
- [Ethics-Safety](Topics/Ethics-Safety/index.md)

### Course View
- [L1 Foundations](Courses/L1%20Foundations/index.md)
- [L2 Workflow](Courses/L2%20Workflow/index.md)
- [L3 Agentic & MCP](Courses/L3%20Agentic%20%26%20MCP/index.md)
- [L4 Claude Code](Courses/L4%20Claude%20Code/index.md)
- [Bonus Cloud](Courses/Bonus%20Cloud/index.md)

## 🗂 Repository Structure

```text
.
├── index.md
├── README.md
├── Courses/
│   ├── index.md
│   ├── L1 Foundations/
│   │   ├── AI Fluency/
│   │   ├── Claude 101/
│   │   └── Intro to Claude Cowork/
│   ├── L2 Workflow/
│   │   └── Building with the Claude API/
│   ├── L3 Agentic & MCP/
│   │   ├── Intro to Agent Skills/
│   │   ├── Intro to MCP/
│   │   ├── Intro to SubAgents/
│   │   └── MCP Advanced Topics/
│   ├── L4 Claude Code/
│   │   └── Claude Code in Action/
│   └── Bonus Cloud/
│       ├── Claude on Amazon Bedrock/
│       └── Claude on Google Vertex AI/
├── Data/
│   ├── index.md
│   ├── Lessons Log.csv
│   ├── Lessons Log_all.csv
│   ├── Topics Index.csv
│   └── Topics Index_all.csv
└── Topics/
    ├── index.md
    ├── Foundations/
    ├── Prompting/
    ├── API-Tools/
    │   ├── Claude API/
    │   └── Agent Tooling/
    ├── Agents-MCP/
    │   ├── Agent Patterns/
    │   ├── MCP Core/
    │   ├── Cowork/
    │   └── Retrieval/
    ├── Claude Code/
    └── Ethics-Safety/
```

## 🧭 How to Navigate

### Option 1: Explore by concept
Start from [`Topics/`](Topics/index.md). This is the primary navigation layer and the best way to study the material as a connected knowledge system.

### Option 2: Explore by course
Use [`Courses/`](Courses/index.md) if you want to reconstruct how topics relate to specific course tracks and levels.

### Option 3: Inspect original exports
Use [`Data/`](Data/index.md) for the original CSV database exports:
- [`Topics Index.csv`](Data/Topics%20Index.csv)
- [`Lessons Log.csv`](Data/Lessons%20Log.csv)

## 🧠 Knowledge Map

The repository is organized around six conceptual areas:

- **Foundations**  
  Models, tokens, lifecycle, artifacts, fluency, and core mental models.  
  See: [`Topics/Foundations`](Topics/Foundations/index.md)

- **Prompting**  
  Prompt design, system prompts, few-shot patterns, structured tasks, reasoning patterns.  
  See: [`Topics/Prompting`](Topics/Prompting/index.md)

- **API-Tools**  
  Claude API mechanics plus agent-oriented tooling such as evals, SDKs, and skills via API.  
  See: [`Topics/API-Tools`](Topics/API-Tools/index.md)

- **Agents-MCP**  
  Agent architecture, subagents, memory, workflow patterns, MCP internals, retrieval, and Cowork.  
  See: [`Topics/Agents-MCP`](Topics/Agents-MCP/index.md)

- **Claude Code**  
  Product-specific notes on setup, architecture, context management, multi-tool workflows, and GitHub integration.  
  See: [`Topics/Claude Code`](Topics/Claude%20Code/index.md)

- **Ethics-Safety**  
  Alignment, bias, responsible use, and security in agentic systems.  
  See: [`Topics/Ethics-Safety`](Topics/Ethics-Safety/index.md)

## 🌱 Start Here

If you are new to the repository, use this path:

1. [`Topics`](Topics/index.md)
2. [`Foundations`](Topics/Foundations/index.md)
3. [`Prompting`](Topics/Prompting/index.md)
4. [`API-Tools`](Topics/API-Tools/index.md)
5. [`Agents-MCP`](Topics/Agents-MCP/index.md)
6. [`Claude Code`](Topics/Claude%20Code/index.md)
7. [`Ethics-Safety`](Topics/Ethics-Safety/index.md)

This gives you a clean progression from fundamentals to practical systems and finally to safety and governance.

## 📚 Recommended Learning Order

### Path A: Topic-first
Best for building a strong conceptual map.

1. [`Foundations`](Topics/Foundations/index.md)
2. [`Prompting`](Topics/Prompting/index.md)
3. [`API-Tools`](Topics/API-Tools/index.md)
4. [`Agents-MCP / Agent Patterns`](Topics/Agents-MCP/Agent%20Patterns/index.md)
5. [`Agents-MCP / MCP Core`](Topics/Agents-MCP/MCP%20Core/index.md)
6. [`Claude Code`](Topics/Claude%20Code/index.md)
7. [`Ethics-Safety`](Topics/Ethics-Safety/index.md)

### Path B: Course-first
Best if you want to mirror the original training progression.

1. [`L1 Foundations`](Courses/L1%20Foundations/index.md)
2. [`L2 Workflow`](Courses/L2%20Workflow/index.md)
3. [`L3 Agentic & MCP`](Courses/L3%20Agentic%20%26%20MCP/index.md)
4. [`L4 Claude Code`](Courses/L4%20Claude%20Code/index.md)
5. [`Bonus Cloud`](Courses/Bonus%20Cloud/index.md)

## 🔑 Key Topics

A few strong entry points if you want immediate orientation:

- [`Come funzionano i Large Language Model`](Topics/Foundations/Come%20funzionano%20i%20Large%20Language%20Model.md)
- [`Context Window e Token`](Topics/Foundations/Context%20Window%20e%20Token.md)
- [`Anatomia di un prompt efficace`](Topics/Prompting/Anatomia%20di%20un%20prompt%20efficace.md)
- [`Messages API - struttura e parametri`](Topics/API-Tools/Claude%20API/Messages%20API%20-%20struttura%20e%20parametri.md)
- [`Tool Use (Function Calling)`](Topics/API-Tools/Claude%20API/Tool%20Use%20%28Function%20Calling%29.md)
- [`Agentic loop e autonomia`](Topics/Agents-MCP/Agent%20Patterns/Agentic%20loop%20e%20autonomia.md)
- [`Model Context Protocol - architettura`](Topics/Agents-MCP/MCP%20Core/Model%20Context%20Protocol%20-%20architettura.md)
- [`Architettura di Claude Code`](Topics/Claude%20Code/Architettura%20di%20Claude%20Code.md)
- [`Responsible use e bias`](Topics/Ethics-Safety/Responsible%20use%20e%20bias.md)

## 🛠 Maintenance Notes

- `index.md` files act as folder landing pages and should remain the main navigation layer.
- `Topics/` is the primary taxonomy.
- `Courses/` is a secondary, course-based access path.
- `Data/` preserves the original Notion-style exports separately from the curated knowledge base.

## 🤝 Contribution

If you extend the repository, prefer:
- adding new notes to the most relevant topic folder
- updating the local `index.md` for that folder
- preserving the topic-first organization rather than duplicating content across multiple areas

---

Use [`index.md`](index.md) as the homepage, [`Topics/`](Topics/index.md) as the main map, and [`Courses/`](Courses/index.md) when you want the learning material grouped by course rather than by concept.
