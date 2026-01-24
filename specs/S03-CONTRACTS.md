# S03: Contracts - simple_uuid

## Date: 2026-01-23 (Backwash)

## Class Invariants

```eiffel
invariant
    random_exists: random /= Void
```

## Feature Contracts

### UUID v4

#### new_v4
```eiffel
ensure
    correct_length: Result.count = 16
    version_4: (Result [7] & 240) = 64
    variant_rfc4122: (Result [9] & 192) = 128
```

#### new_v4_string
```eiffel
ensure
    valid_format: is_valid_uuid (Result)
    correct_length: Result.count = 36
```

#### new_v4_compact
```eiffel
ensure
    no_hyphens: not Result.has ('-')
    correct_length: Result.count = 32
```

### UUID v5

#### new_v5
```eiffel
require
    valid_namespace: a_namespace.count = 16
    name_not_void: a_name /= Void
ensure
    correct_length: Result.count = 16
    version_5: (Result [7] & 240) = 80
    variant_rfc4122: (Result [9] & 192) = 128
```

#### new_v5_string
```eiffel
require
    valid_namespace: a_namespace.count = 16
    name_not_void: a_name /= Void
ensure
    valid_format: is_valid_uuid (Result)
    correct_length: Result.count = 36
```

#### new_v5_dns
```eiffel
require
    domain_not_void: a_domain /= Void
    domain_not_empty: not a_domain.is_empty
ensure
    valid_format: is_valid_uuid (Result)
```

#### new_v5_url
```eiffel
require
    url_not_void: a_url /= Void
    url_not_empty: not a_url.is_empty
ensure
    valid_format: is_valid_uuid (Result)
```

### UUID v7

#### new_v7
```eiffel
ensure
    correct_length: Result.count = 16
    version_7: (Result [7] & 240) = 112
    variant_rfc4122: (Result [9] & 192) = 128
```

#### new_v7_string
```eiffel
ensure
    valid_format: is_valid_uuid (Result)
    correct_length: Result.count = 36
```

#### new_v7_compact
```eiffel
ensure
    no_hyphens: not Result.has ('-')
    correct_length: Result.count = 32
```

### Formatting

#### to_string
```eiffel
require
    valid_uuid: a_uuid.count = 16
ensure
    correct_format: Result.count = 36
    has_hyphens: Result.occurrences ('-') = 4
```

#### to_compact_string
```eiffel
require
    valid_uuid: a_uuid.count = 16
ensure
    correct_length: Result.count = 32
    no_hyphens: not Result.has ('-')
```

### Parsing

#### from_string
```eiffel
require
    valid_input: is_valid_uuid (a_string) or is_valid_uuid_compact (a_string)
ensure
    correct_length: Result.count = 16
```

### Validation

#### is_valid_uuid
```eiffel
require
    string_not_void: a_string /= Void
```

#### is_valid_uuid_compact
```eiffel
require
    string_not_void: a_string /= Void
```

### Version Detection

#### version
```eiffel
require
    valid_uuid: a_uuid.count = 16
ensure
    valid_version: Result >= 0 and Result <= 15
```

#### version_from_string
```eiffel
require
    valid_uuid: is_valid_uuid (a_string) or is_valid_uuid_compact (a_string)
ensure
    valid_version: Result >= 0 and Result <= 15
```

### Comparison

#### is_nil
```eiffel
require
    valid_uuid: a_uuid.count = 16
```

#### is_max
```eiffel
require
    valid_uuid: a_uuid.count = 16
```

### Constants

#### nil_uuid
```eiffel
ensure
    correct_length: Result.count = 16
    is_nil: is_nil (Result)
```

#### max_uuid
```eiffel
ensure
    correct_length: Result.count = 16
    is_max: is_max (Result)
```

### Namespace UUIDs

#### Namespace_dns, Namespace_url, Namespace_oid, Namespace_x500
```eiffel
ensure
    correct_length: Result.count = 16
```
