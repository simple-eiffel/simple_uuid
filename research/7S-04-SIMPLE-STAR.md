# 7S-04: simple_* Integration - simple_uuid


**Date**: 2026-01-23

## Date: 2026-01-23 (Backwash)

## Dependencies Used

| Library | Purpose |
|---------|---------|
| simple_datetime | Unix timestamp for UUID v7 |

## Downstream Consumers

| Library | Usage |
|---------|-------|
| simple_json | Object IDs in JSON |
| simple_http | Request correlation IDs |
| simple_jwt | JWT jti claim |
| simple_sql | Database primary keys |
| simple_websocket | Connection identifiers |

## Integration Points

### simple_datetime Integration
```eiffel
-- UUID v7 timestamp from simple_datetime
unix_ms := datetime.unix_milliseconds
```

### simple_json Integration
```eiffel
-- UUID as JSON value
json.add ("id", uuid_gen.new_v4_string)
```

## Ecosystem Fit

| Aspect | Assessment |
|--------|------------|
| Naming | Follows simple_* convention |
| API style | Facade pattern (SIMPLE_UUID) |
| Contracts | Full DBC coverage |
| SCOOP | Compatible (stateless operations) |
| Dependencies | Minimal (base + simple_datetime) |
