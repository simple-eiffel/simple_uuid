# S02: Class Catalog - simple_uuid

## Date: 2026-01-23 (Backwash)

## Classes

| Class | Role | Exported |
|-------|------|----------|
| SIMPLE_UUID | Facade | Yes |

## SIMPLE_UUID

### Purpose
UUID generation facade supporting v4 (random), v5 (namespace), and v7 (timestamp).

### Inheritance
- ANY (standard)

### Creation
- `make` - Initialize with enhanced entropy seeding

### Feature Groups

| Group | Count |
|-------|-------|
| UUID v4 (Random) | 3 |
| UUID v5 (Namespace SHA-1) | 4 |
| UUID v7 (Timestamp) | 3 |
| Formatting | 2 |
| Parsing | 1 |
| Validation | 2 |
| Version Detection | 2 |
| Comparison | 2 |
| Namespace UUIDs | 4 |
| Constants | 5 |

### Internal Features (Not Exported)
- SHA-1 implementation
- PRNG state management
- Monotonicity counter
