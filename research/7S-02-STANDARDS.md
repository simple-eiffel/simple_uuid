# 7S-02: Standards Research - simple_uuid


**Date**: 2026-01-23

## Date: 2026-01-23 (Backwash)

## Applicable Standards

### RFC 4122 - A Universally Unique IDentifier (UUID) URN Namespace
| Aspect | Requirement |
|--------|-------------|
| Format | 8-4-4-4-12 hexadecimal |
| Variant | Bits 6-7 of clock_seq_hi_and_reserved = 10 |
| Version | Bits 4-7 of time_hi_and_version |
| Namespace UUIDs | DNS, URL, OID, X.500 defined |

### RFC 9562 - Universally Unique IDentifiers (UUIDs)
| Aspect | Requirement |
|--------|-------------|
| UUID v7 | 48-bit Unix millisecond timestamp |
| Monotonicity | Same-millisecond UUIDs must be sortable |
| Nil UUID | 00000000-0000-0000-0000-000000000000 |
| Max UUID | ffffffff-ffff-ffff-ffff-ffffffffffff |

## Version-Specific Requirements

### UUID v4 (Random)
- 122 random bits
- Version nibble = 4
- Variant bits = 10

### UUID v5 (SHA-1 Namespace)
- SHA-1 hash of namespace + name
- Deterministic (same input = same output)
- Version nibble = 5
- Truncate hash to 128 bits

### UUID v7 (Timestamp)
- 48-bit Unix millisecond timestamp
- 12 random bits
- Sequence counter for monotonicity
- Version nibble = 7

## Compliance Matrix

| Standard | Status |
|----------|--------|
| RFC 4122 | Compliant |
| RFC 9562 | Compliant |
| UUID v4 format | Compliant |
| UUID v5 format | Compliant |
| UUID v7 format | Compliant |
