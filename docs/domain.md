# IncidentHub Domain Model

This document defines the core domain entities, their responsibilities, tenancy boundaries, and relationships.

The system is **multi-tenant**. The tenant boundary is the **Organization**.
Cross-tenant access is treated as a security bug.

---

## Tenancy and Isolation Rules

### Tenant root

- **Organization** is the tenant root.
- All tenant-scoped records MUST include `organization_id`.

### Global identity vs tenant access

- **User** is a global identity.
- A user’s access to a tenant is granted via **Membership**.

### Hard requirements

- Every request must resolve a tenant context (an `organization_id`) for tenant-scoped operations.
- Background jobs MUST carry `organization_id` explicitly (and any correlation identifiers).
- Cache keys, idempotency keys, and audit records MUST be tenant-aware.

### Fail-closed posture

If tenant context is missing or ambiguous, the request MUST fail.

---

## Entity Index

- Organization (tenant root)
- User (global identity)
- Membership (user ↔ organization)
- Role (authorization scope)
- Service (monitored system)
- Incident (lifecycle object)
- IncidentEvent (immutable timeline)
- APIKey (machine auth)
- IdempotencyKey (dedupe/replay protection)
- AuditLog (security/compliance trail)

---

## Entities

## Organization

**Purpose**

- Represents a tenant/account. Owns all tenant-scoped resources.

**Scope**

- Tenant root.

**Key Fields (proposed)**

- `id` (UUID)
- `name`
- `status` (`active`, `suspended`)
- `created_at`, `updated_at`

**Relationships**

- has many Memberships
- has many Users through Memberships
- has many Services
- has many Incidents
- has many IncidentEvents (through incidents)
- has many APIKeys
- has many AuditLogs
- has many IdempotencyKeys

**Lifecycle**

- `active` Organization is in good standing and using the platform
- `suspended` implies operational restrictions (e.g., block ingestion, block UI writes).

---

## User

**Purpose**

- Represents a human identity used for web access.

**Scope**

- Global (not tenant-scoped).

**Key Fields (proposed)**

- `id` (UUID)
- `email` (unique)
- `password_digest` (or equivalent)
- `status` (`active`, `disabled`)
- `deleted_at` (soft-delete)
- `created_at`, `updated_at`

**Relationships**

- has many Memberships
- has many Organizations through Memberships
- creates/acts on Incidents via IncidentEvents (actor attribution)
- appears in AuditLogs as actor

**Notes**

- User identity is global; permissions are always evaluated per tenant via Membership.

---

## Membership

**Purpose**

- Grants a User access to an Organization.
- Defines the User’s role within that Organization.

**Scope**

- Tenant-scoped via `organization_id`.

**Key Fields (proposed)**

- `id` (UUID)
- `organization_id`
- `user_id`
- `role` (see Role)
- `created_at`, `updated_at`

**Constraints**

- Unique (`organization_id`, `user_id`) to prevent duplicate memberships.

**Relationships**

- belongs to Organization
- belongs to User

---

## Role

**Purpose**

- Defines authorization scope for a Membership.

**Scope**

- Tenant-scoped (applies within an Organization).

**Proposed Values**

- `owner`: full access, can manage billing, keys, memberships
- `admin`: full access except some org-level operations (optional distinction)
- `member`: standard operational access (create/ack/resolve incidents)
- `read_only`: view-only access

**Notes**

- Roles may evolve into a permission matrix, but start simple.

---

## Service

**Purpose**

- A monitored system/component that can emit incidents.
- Used for routing, grouping, and reporting.

**Scope**

- Tenant-scoped.

**Key Fields (proposed)**

- `id` (UUID)
- `organization_id`
- `name`
- `slug` or `external_id` (unique per org)
- `status` (`active`, `archived`)
- `created_at`, `updated_at`

**Constraints**

- Unique (`organization_id`, `slug`/`external_id`)

**Relationships**

- belongs to Organization
- has many Incidents

---

## Incident

**Purpose**

- Represents an operational incident with a lifecycle.

**Scope**

- Tenant-scoped.

**Key Fields (proposed)**

- `id` (UUID)
- `organization_id`
- `service_id`
- `title`
- `description` (optional)
- `status` (`triggered`, `acknowledged`, `resolved`)
- `triggered_at`
- `acknowledged_at` (nullable)
- `resolved_at` (nullable)
- `created_at`, `updated_at`

**Relationships**

- belongs to Organization
- belongs to Service
- has many IncidentEvents

**Lifecycle / Invariants**

- `triggered` → `acknowledged` → `resolved`
- Timestamps must align with state transitions.
- All changes must be represented in IncidentEvents.

---

## IncidentEvent

**Purpose**

- Immutable timeline of everything that happened to an Incident.
- Enables auditability and reconstruction.

**Scope**

- Tenant-scoped (via incident + organization_id).

**Key Fields (proposed)**

- `id` (UUID)
- `organization_id`
- `incident_id`
- `type` (event type enum/string)
- `occurred_at`
- `actor_type` (`user`, `api_key`, `system`)
- `actor_id` (nullable for system)
- `metadata` (JSONB)
- `created_at`

**Event Types (initial)**

- `incident.triggered`
- `incident.acknowledged`
- `incident.resolved`
- `comment.added`
- `integration.ingested`

**Immutability**

- Append-only.
- Never updated in place after creation.

---

## APIKey

**Purpose**

- Machine-to-machine authentication for ingestion and integrations.

**Scope**

- Tenant-scoped.

**Key Fields (proposed)**

- `id` (UUID)
- `organization_id`
- `name`
- `key_hash` (store hash only; never store plaintext)
- `prefix` (optional, non-secret identifier for debugging)
- `scopes` (array or JSON)
- `last_used_at` (nullable)
- `revoked_at` (nullable)
- `created_at`, `updated_at`

**Constraints**

- Keys are rotatable. Rotation implies issuing a new key and revoking the old.

---

## IdempotencyKey

**Purpose**

- Protects ingestion endpoints from duplicates/replays.
- Ensures retries do not create duplicate Incidents.

**Scope**

- Tenant-scoped.

**Key Fields (proposed)**

- `id` (UUID)
- `organization_id`
- `key` (string; unique per org)
- `request_hash` (optional: detect mismatched payload for same key)
- `resource_type` / `resource_id` (optional: link to created incident)
- `expires_at`
- `created_at`

**Constraints**

- Unique (`organization_id`, `key`)
- Expiration policy (e.g., 24h) to bound storage

---

## AuditLog

**Purpose**

- Immutable record of security- and business-critical actions.

**Scope**

- Tenant-scoped.

**Key Fields (proposed)**

- `id` (UUID)
- `organization_id`
- `action` (string)
- `actor_type` (`user`, `api_key`, `system`)
- `actor_id` (nullable)
- `target_type` (string)
- `target_id` (string/uuid)
- `metadata` (JSONB)
- `request_id` / `correlation_id` (string)
- `occurred_at`
- `created_at`

**Immutability**

- Append-only.

**Examples**

- membership.role_changed
- api_key.created
- api_key.revoked
- incident.state_changed

---

## Relationships (Summary)

- Organization
  - has many Memberships
  - has many Users through Memberships
  - has many Services
  - has many Incidents
  - has many IncidentEvents (through Incidents)
  - has many APIKeys
  - has many IdempotencyKeys
  - has many AuditLogs

- User
  - has many Memberships
  - has many Organizations through Memberships

- Service
  - belongs to Organization
  - has many Incidents

- Incident
  - belongs to Organization
  - belongs to Service
  - has many IncidentEvents

- IncidentEvent
  - belongs to Organization
  - belongs to Incident
  - optionally references an actor (User/APIKey/System)

---

## Open Questions (Intentionally Deferred)

These are intentionally deferred until the core system is running:

- Escalation policies / schedules / on-call rotations
- Notification channels (email/slack/pager)
- Multi-region considerations
- Data retention policy and archival strategy
- Advanced permissions (fine-grained vs role-based)
- Cross-org SSO (SAML/OIDC)

---

## Guardrails for Implementation

- Tenant scoping must be enforced in:
  - controllers
  - queries
  - background jobs
  - idempotency logic
  - audit logging
- Every mutation that matters must produce:
  - an IncidentEvent (incident-focused changes)
  - and/or an AuditLog entry (security/compliance changes)
