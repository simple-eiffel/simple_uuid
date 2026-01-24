# 7S-05: Security Analysis - simple_uuid

## Date: 2026-01-23 (Backwash)

## Security Considerations

### PRNG Quality

| Aspect | Status |
|--------|--------|
| Random source | Eiffel RANDOM class |
| Cryptographic | NO |
| Entropy sources | Time + date + counter |
| Suitability | General identifiers only |

### NOT Suitable For
- Session tokens (use OS secure random)
- Cryptographic keys
- Security tokens
- Sensitive identifiers

### Suitable For
- Database primary keys
- Correlation IDs
- Request tracing
- Log identifiers
- General unique IDs

## UUID v5 Security

| Aspect | Assessment |
|--------|------------|
| Hash algorithm | SHA-1 |
| SHA-1 status | Cryptographically broken |
| UUID v5 impact | Still safe for UUID generation |
| Reason | Collision resistance not required |

## Information Leakage

### UUID v7
| Risk | Mitigation |
|------|------------|
| Timestamp exposure | Creation time visible |
| Ordering exposure | Can infer creation sequence |
| Recommendation | Use v4 if timing is sensitive |

### UUID v5
| Risk | Mitigation |
|------|------------|
| Name recovery | Cannot recover name from UUID |
| Namespace exposure | Namespace is public constant |
| Recommendation | Safe for general use |

## Recommendations

1. **Document limitations** - Clear security notes in API
2. **Don't use for security** - Not cryptographically secure
3. **Use v4 for anonymity** - No timing information
4. **Use v7 for databases** - Sortable, index-friendly
