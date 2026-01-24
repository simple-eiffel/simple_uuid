# S06: Boundaries - simple_uuid

## Date: 2026-01-23 (Backwash)

## System Boundaries

### Input Boundary
| Input | Type | Validation |
|-------|------|------------|
| Namespace UUID | ARRAY[NATURAL_8] | count = 16 |
| Name for v5 | STRING_8 | Not void |
| Domain for v5_dns | STRING_8 | Not void, not empty |
| URL for v5_url | STRING_8 | Not void, not empty |
| UUID string | STRING_8 | Valid format |
| UUID bytes | ARRAY[NATURAL_8] | count = 16 |

### Output Boundary
| Output | Type | Guarantee |
|--------|------|-----------|
| UUID bytes | ARRAY[NATURAL_8] | count = 16 |
| UUID string | STRING_8 | 36 chars, hyphenated |
| UUID compact | STRING_8 | 32 chars, no hyphens |
| Version | INTEGER_32 | 0-15 |
| Validation | BOOLEAN | Accurate |

## Integration Boundaries

### Upstream (Consumers)
| Library | Usage |
|---------|-------|
| simple_json | JSON object IDs |
| simple_http | Request correlation |
| simple_jwt | jti claim |
| simple_sql | Primary keys |
| simple_websocket | Connection IDs |

### Downstream (Dependencies)
| Library | Usage |
|---------|-------|
| base | STRING, ARRAY, RANDOM |
| simple_datetime | Unix timestamps for v7 |

## Error Handling Boundary

| Condition | Handling |
|-----------|----------|
| Void namespace | Precondition violation |
| Void name | Precondition violation |
| Invalid UUID string | Precondition violation |
| Wrong byte count | Precondition violation |

## Feature Boundary

### Included
- UUID v4 (random)
- UUID v5 (namespace SHA-1)
- UUID v7 (timestamp)
- String formatting
- Parsing
- Validation
- Version detection
- Standard namespaces

### Excluded
- UUID v1 (MAC-based)
- UUID v3 (MD5)
- UUID v6 (reordered v1)
- UUID v8 (custom)
- Cryptographic random
- Database-specific formats
