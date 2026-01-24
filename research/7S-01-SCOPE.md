# 7S-01: Scope Analysis - simple_uuid

## Date: 2026-01-23 (Backwash)

## Problem Domain

UUID (Universally Unique Identifier) generation is fundamental for distributed systems, database keys, and correlation IDs. Eiffel lacks a native UUID library that supports modern UUID versions (v7) and provides proper contracts.

## Target Users

| User Type | Need |
|-----------|------|
| Database developers | Primary keys without coordination |
| Distributed systems | Correlation IDs, trace IDs |
| Web developers | Session tokens, resource identifiers |
| API developers | Request/response correlation |

## Scope Boundaries

### In Scope
- UUID v4 (random, 122 bits)
- UUID v5 (namespace-based SHA-1)
- UUID v7 (timestamp-based, sortable)
- String formatting (hyphenated and compact)
- Parsing from string
- Validation
- Standard namespace constants (DNS, URL, OID, X.500)
- Nil and max UUID constants

### Out of Scope
- UUID v1 (MAC address based - privacy concerns)
- UUID v3 (MD5 - deprecated)
- UUID v6 (reordered v1 - rarely used)
- UUID v8 (custom - application-specific)
- Cryptographically secure random (OS-level)
- Database-specific optimizations

## Success Criteria

| Criterion | Measure |
|-----------|---------|
| RFC compliance | RFC 4122, RFC 9562 |
| Contract coverage | 100% |
| Test coverage | Unit tests for all versions |
| Performance | Sub-millisecond generation |
