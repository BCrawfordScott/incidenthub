# IncidentHub

IncidentHub is a multi-tenant incident management platform designed with enterprise-scale patterns from day one.  
It focuses on **correctness, isolation, observability, and operational safety** rather than feature velocity.

The project is intentionally built as a realistic production system, not a demo app.

---

## Why IncidentHub Exists

Most portfolio projects demonstrate *features*.  
IncidentHub aims to demonstrate **systems thinking**.

This project emphasizes:
- strict tenant isolation
- explicit authorization boundaries
- async-safe ingestion
- operational observability
- infrastructure-aware design

The goal is to reflect how modern, high-scale SaaS systems are actually built and evolved.

---

## Architecture Overview

IncidentHub is structured as a monorepo with clear service boundaries:

incidenthub/
├── api/ # Rails API (multi-tenant, async-first)
├── web/ # Next.js frontend (BFF-style)
├── infra/ # Infrastructure definitions (AWS / Terraform)
├── docker-compose.yml
└── README.md

### Backend (API)
- **Ruby on Rails (API mode)**
- **PostgreSQL** for relational data
- **Redis + Sidekiq** for background processing
- Policy-based authorization
- Explicit tenant scoping

### Frontend (Web)
- **Next.js (TypeScript)**
- Centralized API client
- Runtime contract validation (Zod)
- Auth-aware application shell

### Infrastructure (Planned)
- **AWS ECS** (API + worker services)
- **ALB** for routing
- **RDS Postgres**
- **ElastiCache Redis**
- **Secrets Manager / IAM**

---

## Core Design Principles

### 1. Multi-Tenancy Is Non-Negotiable
Organizations are the primary isolation boundary.  
Cross-tenant access is treated as a security bug, not a feature gap.

Tenant context is resolved per request and enforced consistently.

---

### 2. Fail Closed by Default
Authorization is explicit.
Missing context or unclear intent results in request failure.

This avoids the most common class of SaaS security bugs.

---

### 3. Async Where It Matters
External ingestion and high-latency workflows are processed asynchronously.

Synchronous endpoints remain fast and predictable.

---

### 4. Observability Is a First-Class Concern
Every request and background job is traceable via correlation IDs.

Logs are structured and designed for aggregation, not eyeballing.

---

### 5. Enterprise-Friendly Evolution
The system is designed to:
- evolve APIs without breaking clients
- support multiple clients (web, API, integrations)
- scale infrastructure without rewriting application code

---

## Domain Model (High-Level)

- **Organization** — tenant root
- **User** — global identity
- **Membership** — user ↔ organization join
- **Role** — authorization scope
- **Service** — monitored system
- **Incident** — lifecycle-managed event
- **IncidentEvent** — immutable timeline
- **APIKey** — machine access
- **AuditLog** — security and compliance trail

A full domain breakdown lives in `docs/domain.md`.

---

## Local Development

### Prerequisites
- Ruby 3.3.x
- Node.js 20.x
- Docker + Docker Compose
- `asdf` (recommended)

Versions are pinned via `.tool-versions`.

---

### Booting the Stack

Start infrastructure dependencies:
```bash
make up
```
Run the API + worker:
```bash
cd api
overmind start -f Procfile.dev
```
Or individually:
```bash
make api
make worker
```
Services:
- API: <http://localhost:3001>
- Sidekiq UI (dev only): <http://localhost:3001/sidekiq>
- Web (Next.js): <http://localhost:3000>

## API Versioning

All API routes are namespaced:
```
/api/v1
```
This allows future versions to coexist without breaking clients.

## Authentication Strategy

IncidentHub uses session-based authentication for browser clients:

- httpOnly cookies
- CSRF protection
- BFF-style communication via Next.js

API keys are supported for machine-to-machine access.

## Background Processing

- Sidekiq is used for all asynchronous work

- Redis is required

- Jobs propagate request correlation IDs for traceability

## Project Status

This project is actively developed with intentional sequencing:

- Foundations first

- Features second

- Scaling last

Tracked via GitHub Issues with clear priorities and acceptance criteria.

## Non-Goals

This project intentionally does not:

- optimize for UI polish early

- use GraphQL

- chase framework novelty

- hide complexity behind generators

Clarity and correctness are prioritized over speed.

## License

MIT License

Copyright (c) 2026 Brian Crawford Scott

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Author

Brian Crawford Scott

Built by a senior software engineer as a realistic demonstration of production-grade system design and execution.
