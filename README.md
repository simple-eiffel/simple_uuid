<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/.github/main/profile/assets/logo.svg" alt="simple_ library logo" width="400">
</p>

# simple_uuid

**[Documentation](https://simple-eiffel.github.io/simple_uuid/)** | **[Watch the Build Video](https://youtu.be/zZmpyOlztK8)**

Lightweight UUID generation library for Eiffel.

## Features

- **UUID v4** - Random UUIDs (122 random bits)
- **UUID v7** - Timestamp-based, sortable UUIDs
- **Parsing** - Parse UUIDs from strings
- **Validation** - Validate UUID format
- **Design by Contract** - Full preconditions/postconditions

## Installation

Add to your ECF:

```xml
<library name="simple_uuid" location="$SIMPLE_EIFFEL/simple_uuid/simple_uuid.ecf"/>
```

Set environment variable (one-time setup for all simple_* libraries):
```
SIMPLE_EIFFEL=D:\prod
```

## Usage

### Generate UUID v4 (Random)

```eiffel
local
    gen: SIMPLE_UUID
    id: STRING
do
    create gen.make

    -- As string
    id := gen.new_v4_string
    -- Result: "550e8400-e29b-41d4-a716-446655440000"

    -- Compact (no hyphens)
    id := gen.new_v4_compact
    -- Result: "550e8400e29b41d4a716446655440000"

    -- As bytes
    bytes := gen.new_v4
end
```

### Generate UUID v7 (Timestamp)

UUID v7 embeds a Unix millisecond timestamp, making UUIDs sortable by creation time.

```eiffel
local
    gen: SIMPLE_UUID
    id: STRING
do
    create gen.make

    id := gen.new_v7_string
    -- First 48 bits encode creation timestamp
    -- UUIDs created later sort after earlier ones
end
```

### Parse UUID

```eiffel
local
    gen: SIMPLE_UUID
    uuid: ARRAY [NATURAL_8]
do
    create gen.make

    -- Parse hyphenated
    uuid := gen.from_string ("550e8400-e29b-41d4-a716-446655440000")

    -- Parse compact
    uuid := gen.from_string ("550e8400e29b41d4a716446655440000")
end
```

### Validate UUID

```eiffel
if gen.is_valid_uuid (some_string) then
    uuid := gen.from_string (some_string)
end

if gen.is_valid_uuid_compact (compact_string) then
    -- ...
end
```

### Version Detection

```eiffel
version := gen.version (uuid_bytes)
-- or
version := gen.version_from_string ("550e8400-e29b-41d4-a716-446655440000")
```

## UUID Versions

| Version | Description | Use Case |
|---------|-------------|----------|
| v4 | 122 random bits | General purpose, most common |
| v7 | 48-bit timestamp + random | Database keys (sortable), distributed systems |

## API Reference

### Generation

| Feature | Description |
|---------|-------------|
| `new_v4` | Random UUID as bytes |
| `new_v4_string` | Random UUID as hyphenated string |
| `new_v4_compact` | Random UUID without hyphens |
| `new_v7` | Timestamp UUID as bytes |
| `new_v7_string` | Timestamp UUID as hyphenated string |
| `new_v7_compact` | Timestamp UUID without hyphens |

### Parsing & Formatting

| Feature | Description |
|---------|-------------|
| `from_string (STRING)` | Parse UUID from string |
| `to_string (bytes)` | Format as hyphenated string |
| `to_compact_string (bytes)` | Format without hyphens |

### Validation

| Feature | Description |
|---------|-------------|
| `is_valid_uuid (STRING)` | Check hyphenated format |
| `is_valid_uuid_compact (STRING)` | Check compact format |

### Utilities

| Feature | Description |
|---------|-------------|
| `version (bytes)` | Get version number (1-7) |
| `is_nil (bytes)` | Check if all zeros |
| `nil_uuid` | All-zeros UUID |

## Dependencies

- EiffelBase
- EiffelTime (for timestamps)

## License

MIT License - Copyright (c) 2024-2025, Larry Rix
