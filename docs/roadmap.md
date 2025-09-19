# Holocron: Decentralized Knowledge Sync Layer

## Elevator Pitch
Holocron is your **portable memory layer**: Markdown notes as the source of truth, synced peer-to-peer, and optionally exposed via a web API so humans and AIs can share the same knowledge base. It’s simple, decentralized, and resilient — memory you control, not memory trapped inside one tool.

NOTE: this document outlines what Holocron aims to be, not necessarily what it is just yet.

---

## Executive Summary
Holocron is a **lightweight, decentralized system** for managing long-lived context and project knowledge.  
- **Markdown as canon**: plain text files remain the single source of truth.  
- **Peer-to-peer sync**: devices share selected Holocron folders via Syncthing.  
- **Unified tooling**: the Holocron gem provides CLI commands and optional API endpoints.  
- **AI-ready**: AIs and connectors can query Holocrons over HTTPS with token auth.  
- **Extensible**: future support for staged writes, SQLite indexes, and embedding layers.  

**Why it matters:**  
- Portable memory across tools and platforms.  
- Decentralized resilience: no single point of failure.  
- Works with editors like Obsidian or `grep`, while remaining AI-friendly.  
- Keeps user control of knowledge outside any vendor lock-in.  

---

## Core Components
Every node (laptop, work machine, VPS) runs the same stack:

1. **Syncthing Daemon**  
   - Secure, encrypted P2P sync of selected Holocron folders.  
   - Any node can be “always-on” to improve reliability.  
   - Handles conflicts by renaming; manual merge if needed.  

2. **Holocron Folder**  
   - Markdown files + subfolders.  
   - Browsable in Obsidian or any editor.  
   - No custom formats required.  

3. **Holocron Gem / CLI**  
   - Provides `holo` commands for managing Holocrons.  
   - Can also launch a web service: `holo server start`.  

4. **Holocron Web API (Optional)**  
   - REST-style endpoints:  
     - `/v1/search`  
     - `/v1/file`  
     - `/v1/bundle`  
   - Exposed locally by default.  
   - Optionally proxied through HTTPS with Caddy, Nginx, Cloudflare Tunnel, or Tailscale.  

---

## Remote AIs / Connector Access
- ChatGPT (via Connectors) or other agents can query any node that exposes HTTPS.  
- Access controlled via token auth.  
- Future: staged write API → writes become commits or PRs managed by the gem.  

---

## Advantages
- **Offline first**: continue working while disconnected, sync later.  
- **Portable**: knowledge lives in plain files, not trapped in one app.  
- **Redundant**: no single “master” node.  
- **Optional layers**: stop at CLI, add web API, or go full decentralized.  
- **Extensible**: SQLite or remote DB indexing for faster queries; embedding layers for semantic search.  

---

## Roadmap
- ✅ Local CLI with Markdown.  
- 🚧 Local web API (read-only).  
- 🔜 Syncthing P2P sync across devices.  
- 🔜 HTTPS exposure for AI / connector access.  
- 🔮 Future: staged writes, optional DB indexing, AI embedding search.  

---

## Key Considerations
- **Conflicts**: Syncthing preserves all conflicting versions; human merges as needed.  
- **Performance**: near-real-time sync; offline nodes catch up when online.  
- **Security**: HTTPS + token authentication mandatory if exposed publicly.  
- **Extensibility**: keep the gem modular so features like Syncthing, API, or DBs can be optional.  

---

## TL;DR
Holocron is a **decentralized, AI-friendly memory system**:  
Markdown for humans, Syncthing for sync, a gem for control, and an optional API for machines.  
It’s memory that belongs to you, portable and future-proof.