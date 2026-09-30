# AI Application Layer — SwiftUI Smart Supply Chain Optimization Dashboard

A SwiftUI + SceneKit iPad client for the **ai-application-layer** Gemma RAG
backend, staged as an interactive 3D Smart Supply Chain Optimization Dashboard — motion-tilt parallax,
four seasonal 3D nature weather scenes (Winter with snow, Spring with rain and robotic flower-pouring, Summer with wind and robotic lawn-design, and Autumn with flowing leaves and robotic fruit-sorting). Under the hood it calls
the exact same **Node.js / Express** API — `https://ai-application-layer-extended.vercel.app`,
source at [`saasmodularframework/ai-application-layer-extended`](https://github.com/saasmodularframework/ai-application-layer-extended) —
which ingests only the **Sci/Tech** slice of the AG News dataset directly from
Hugging Face, indexes it in **ChromaDB** using **LlamaIndex.TS** for chunking,
and answers questions about the articles using a **Gemma** model called
through the **Vercel AI SDK (ai-sdk)**.

---

<p>
  <img src="https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/SwiftUI-0066CC?style=for-the-badge&logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/SceneKit-000000?style=for-the-badge&logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/Xcode-147EFB?style=for-the-badge&logo=xcode&logoColor=white" />
  <img src="https://img.shields.io/badge/CoreMotion-1D1D1F?style=for-the-badge&logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/WebKit-1F87FF?style=for-the-badge&logo=webkit&logoColor=white" />
  <img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white" />
  <img src="https://img.shields.io/badge/Express-000000?style=for-the-badge&logo=express&logoColor=white" />
  <img src="https://img.shields.io/badge/Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white" />
  <img src="https://img.shields.io/badge/ChromaDB-121212?style=for-the-badge&logo=databricks&logoColor=white" />
  <img src="https://img.shields.io/badge/Hugging_Face-FFD21E?style=for-the-badge&logo=huggingface&logoColor=black" />
  <img src="https://img.shields.io/badge/Google_Gemma-4285F4?style=for-the-badge&logo=google&logoColor=white" />
  <img src="https://img.shields.io/badge/Vimeo-1AB7EA?style=for-the-badge&logo=vimeo&logoColor=white" />
</p>

---

## Table of contents

- [Tech stack](#tech-stack)
- [Architecture](#architecture)
  - [System overview](#system-overview)
  - [SwiftUI client layer](#swiftui-client-layer)
  - [Node.js backend — ai-application-layer](#nodejs-backend--ai-application-layer)
  - [How data is fetched](#how-data-is-fetched)
- [Repository structure](#repository-structure)
- [Features](#features)
- [Setup and build (.ipa via Apple Configurator)](#setup-and-build-ipa-via-apple-configurator)

---

## Tech stack

*   **Client platform:** macOS Ventura 16.7.8, Xcode 15.2, Apple Configurator
*   **UI framework:** SwiftUI (declarative views, `@StateObject`/`@State` reactivity)
*   **3D scene:** SceneKit — four seasonal 3D nature weather scenes (Winter with snow, Spring with rain and robotic flower-pouring, Summer with wind and robotic lawn-design, Autumn with flowing leaves and robotic fruit-sorting)
*   **Motion input:** CoreMotion (`CMMotionManager`) — device roll drives scene lean + parallax
*   **Networking:** `URLSession` (async/await) against the deployed Node.js API
*   **Deployment target:** iPadOS/iOS, distributed as a signed `.ipa` for installation via Apple Configurator 2 (not App Store)

---

## Architecture

### System overview

The SwiftUI app is a pure **consumer** of the Node.js backend's HTTP API — it
holds no model weights, no vector store, and no dataset locally. Everything
RAG-related (retrieval, embedding, generation) happens server-side; the
client's job is motion input, 3D rendering, and rendering whatever JSON comes
back from `/api/*`.

```mermaid
graph TB
  subgraph iPad["iPad — SwiftUI Client"]
    Motion["MotionManager<br/>CoreMotion device roll"]
    Scene["DashboardScene — SceneKit<br/>skyline / fountain / dashboard node"]
    Panel["DashboardPanelView<br/>ingest + ask UI"]
    API["APIClient<br/>URLSession async/await"]
    Video["PosterVideoBillboard<br/>WKWebView → Vimeo background embed"]
  end

  subgraph Vercel["ai-application-layer — Node.js / Express on Vercel"]
    Index["index.js<br/>/api/health /api/ingest /api/query"]
    Dataset["lib/dataset.js<br/>Hugging Face AG News Sci/Tech loader"]
    Vectorstore["lib/vectorstore.js<br/>LlamaIndex.TS chunking + Chroma upsert/query"]
    Gemma["lib/gemma.js<br/>ai-sdk generateText() → Gemma"]
  end

  HF["Hugging Face datasets-server<br/>ag_news REST API"]
  Chroma["ChromaDB<br/>vector store"]
  GoogleAI["Google AI Studio<br/>Gemma + text-embedding-004"]
  VimeoCDN["Vimeo<br/>player.vimeo.com"]

  Motion --> Scene
  Panel --> API
  API -- "GET /api/health" --> Index
  API -- "POST /api/ingest {limit, split}" --> Index
  API -- "POST /api/query {question, topK}" --> Index
  Index --> Dataset --> HF
  Index --> Vectorstore --> Chroma
  Index --> Gemma --> GoogleAI
  Video -- "background=1&autoplay=1&loop=1&muted=1" --> VimeoCDN
```

| Layer | Contract | Why it's isolated this way |
|---|---|---|
| SwiftUI ↔ Node | `POST /api/ingest {limit, split} → {message, articlesIngested, chunksIngested, sample}`; `POST /api/query {question, topK} → {answer, provider, model, sources[]}` | The client never touches Hugging Face, Chroma, or Gemma directly — it only speaks the same JSON contract `public/index.html` already used, so the web dashboard and this native app are interchangeable frontends for one backend |
| Node ↔ Hugging Face | `datasets-server` REST `rows` endpoint, filtered client-side to `label == 3` (Sci/Tech) | No dataset is bundled with either the backend or the SwiftUI app — articles are fetched live on each ingest call |
| Node ↔ Chroma | LlamaIndex.TS `SentenceSplitter` chunks → `ai-sdk embed()` (`text-embedding-004`) → Chroma upsert/query | Embeddings and chunking stay entirely server-side; the SwiftUI app never sees raw vectors, only the final ranked `sources[]` |
| Node ↔ Gemma | `ai-sdk generateText()` against Google AI Studio's Generative Language API | Swappable model id (`GEMMA_MODEL` env var) without any client-side change |
| SwiftUI ↔ Vimeo | Direct `WKWebView` load of `player.vimeo.com/video/{id}?background=1` | Video playback is entirely client-side and unrelated to the RAG backend |

---

### SwiftUI client layer

- **`MainScene`** — hosts the analytics dashboard with chart cycling, zoom controls, and navigation triggering the transition to seasonal 3D weather scenes upon tapping individual chart outputs.
- **`OfficeBuilder`** — constructs the 3D office interior scene.
- **`DashboardPanelView`** — the actual functional UI (ingest controls, question field, cited answer list), composited against the backend API endpoints.
- **`APIClient`** — thin async/await wrapper matching `index.js`'s exact response shapes; no guessed fields.
- **`Models` & `SeasonScene`** — configure season enum configurations, tasks, color palettes, chart models, and wrapper views for Winter (snow & robotic street snow remover), Spring (rain & robotic flower-pouring), Summer (wind & robotic lawn-design), and Autumn (flowing leaves & robotic fruit-sorting).

### Node.js backend — ai-application-layer

```
Hugging Face (ag_news, Sci/Tech only)
        │  datasets-server REST API
        ▼
  lib/dataset.js  ── fetch + filter label==3
        ▼
  lib/vectorstore.js
        │  LlamaIndex SentenceSplitter → chunks
        │  ai-sdk embed() → text-embedding-004
        ▼
      ChromaDB (vector store)
        ▲
        │  similarity search (top-k)
  lib/vectorstore.js retrieve()
        │
        ▼
  index.js  /api/query
        │  builds RAG prompt with numbered context
        ▼
  lib/gemma.js  ── ai-sdk generateText() → Gemma (gemma-3-27b-it)
        ▼
   Answer + cited sources → SwiftUI DashboardPanelView (or public/index.html)
```

This is the same backend described in the Node app's own README: Express
routes in `index.js`, a Hugging Face loader in `lib/dataset.js`, LlamaIndex.TS
chunking + Chroma storage/retrieval in `lib/vectorstore.js`, and Gemma
generation/embeddings via `ai-sdk` in `lib/gemma.js`. The SwiftUI app adds no
new backend logic — it's a second frontend against the identical API surface
already serving `public/index.html`.

---

### How data is fetched

1. **Ingest, triggered from the SwiftUI dashboard's "Ingest Sci/Tech Articles" button** → `APIClient.ingest(limit:split:)` → `POST https://ai-application-layer.vercel.app/api/ingest`.
2. The Vercel-hosted `index.js` calls `lib/dataset.js`, which pages through Hugging Face's `datasets-server` REST API (`https://datasets-server.huggingface.co/rows?dataset=fancyzhx/ag_news...`), keeping only Sci/Tech-labeled rows (`label == 3`).
3. `lib/vectorstore.js` chunks those articles (LlamaIndex.TS `SentenceSplitter`), embeds each chunk via `ai-sdk`'s `embed()` (`text-embedding-004`), and upserts into ChromaDB.
4. **Querying, from the SwiftUI dashboard's "Ask Gemma" field** → `APIClient.query(_:topK:)` → `POST /api/query {question, topK}`.
5. `index.js` retrieves the top-k nearest chunks from Chroma, builds a numbered-context RAG prompt, and calls `lib/gemma.js`'s `gemmaGenerate()`, which hits Google AI Studio's Gemma endpoint through `ai-sdk`'s `generateText()`.
6. The JSON response (`{answer, provider, model, sources[]}`) is decoded by `APIClient.QueryResponse` and rendered directly in `DashboardPanelView` — no client-side parsing of HTML, no scraping; it's the same structured API the Node app's own dashboard (`public/index.html`) consumes.

No dataset, embeddings, or model weights are ever downloaded to the iPad —
the SwiftUI app only ever sees the final `answer`/`sources` JSON.

---

## Repository structure

```
.
├── AIApplicationLayerApp/
│   ├── AILayerApp.swift                # @main App entry point
│   ├── MainScene.swift                 # Analytics Dashboard host view with chart selection and navigation
│   ├── Models.swift                    # Season enum configurations, tasks, color palettes, and Chart models
│   ├── OfficeBuilder.swift             # SceneKit 3D environment & workstation builder
│   ├── SceneHelpers.swift              # Material generation and lighting setup helpers
│   ├── SeasonScene.swift               # Season-specific SceneContainer wrapper and views
│   ├── DashboardPanelView.swift        # Ingest + Ask UI, wired to APIClient
│   └── APIClient.swift                 # async/await client for /api/health, /api/ingest, /api/query
└── README.md
```

Backend repository (consumed, not vendored — see [ai-application-layer](https://github.com/saasmodularframework/ai-application-layer-extended)):

```
.
├── index.js                # Express app: /api/ingest, /api/query, /api/health
├── lib/
│   ├── dataset.js           # Hugging Face AG News Sci/Tech loader
│   ├── vectorstore.js        # LlamaIndex chunking + ChromaDB storage/retrieval
│   └── gemma.js              # ai-sdk Gemma generation + embeddings
├── public/index.html        # Web dashboard UI (the SwiftUI app's sibling frontend)
├── vercel.json               # Vercel deployment routing
└── .env
```

---

## Features

| Feature | Notes |
|---|---|
| 3D office interior & workstations (SceneKit) | 
| Interactive chart zoom & navigation | Swipe gestures or button controls to cycle through Marimekko, Dendrogram, Stream graph, and Radial bars notebook charts with smooth zooming |
| Four seasonal 3D nature weather scenes | Seasonal destinations accessible by tapping individual chart outputs from the main dashboard scene |
| Winter weather scene | Winter weather featuring realistic snowfall and a robotic street snow remover performing seasonal maintenance |
| Spring weather scene | Spring season featuring falling rain and a robotic arm pouring water on flowers |
| Summer weather scene | Summer environment featuring gentle wind currents and a robotic gardener designing and tending lawns |
| Autumn weather scene | Autumn setting featuring flowing leaves and a robotic sorting mechanism separating fruit by size, shape, color, and weight |
| Ingest + Ask Gemma | `DashboardPanelView` mirrors web functionality against the real `/api/ingest` and `/api/query` backend endpoints |

---

## Setup and build (.ipa via Apple Configurator)

1. Open Xcode (15.2) → **File → New → Project → iOS App**, SwiftUI interface, a clean product name (no punctuation).
2. Drag in all `.swift` files from `rag-application-layer-extended/`, checking **Copy items if needed** and the app target's membership checkbox.
3. **Signing & Capabilities** → select your Apple Developer team.
4. **Info.plist** → confirm `NSMotionUsageDescription` is set (CoreMotion requires it).
5. Build and test on a physical iPad — CoreMotion tilt doesn't work in the Simulator.
6. **Product → Archive** → **Distribute App** → export the `.ipa`.
7. Open **Apple Configurator 2** → drag the exported `.ipa` onto your connected iPad to install it.



