# S05: Constraints - simple_uuid

## Date: 2026-01-23 (Backwash)

## Technical Constraints

### C1: RFC Compliance
All UUID generation must comply with RFC 4122 and RFC 9562.
- Version field in correct position
- Variant field = 10 (RFC 4122)
- Format: 8-4-4-4-12 hexadecimal

### C2: PRNG Quality
Uses Eiffel RANDOM class (NOT cryptographically secure).
- Enhanced seeding: time + date + instance counter
- Suitable for: Database keys, correlation IDs
- NOT suitable for: Security tokens, session IDs

### C3: SHA-1 Implementation
Embedded SHA-1 for v5 UUIDs.
- Full RFC 3174 compliant implementation
- No external crypto dependencies
- Note: SHA-1 is broken for signatures but fine for UUIDs

### C4: Monotonicity (v7)
Same-millisecond UUIDs must maintain ordering.
- Sequence counter incremented within same ms
- Counter reset on new millisecond
- Ensures sortability

### C5: SCOOP Compatibility
Generator is safe for concurrent use.
- Stateless operations (except PRNG state)
- Thread-local PRNG recommended for heavy use
- SCOOP support: compatible

## Design Constraints

### C6: Single Class
All functionality in SIMPLE_UUID.
- No inheritance hierarchy
- No helper classes exposed
- Simple usage pattern

### C7: Minimal Dependencies
Only base and simple_datetime required.
- No Gobo dependency
- No external crypto libraries
- Simpler deployment

## Performance Constraints

### C8: Generation Speed
All versions generate in sub-millisecond time.
- v4: < 0.1ms (random only)
- v5: < 5ms (SHA-1 computation)
- v7: < 0.1ms (timestamp + random)

### C9: Memory Allocation
Minimal allocations per generation.
- UUID bytes: 16 bytes
- String result: 36 or 32 bytes
- No intermediate buffers (except SHA-1)
