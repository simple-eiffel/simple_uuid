# S04: Feature Specifications - simple_uuid

## Date: 2026-01-23 (Backwash)

## UUID v4 (Random)

### new_v4: ARRAY [NATURAL_8]
Generate a new random UUID v4 (122 random bits).

**Format:** xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx (y = 8, 9, a, or b)

**Implementation:** Uses Eiffel RANDOM class seeded with time+date+counter.

### new_v4_string: STRING_8
Generate a new random UUID v4 as hyphenated string.

**Implementation:** Calls `new_v4` then `to_string`.

### new_v4_compact: STRING_8
Generate a new random UUID v4 without hyphens.

**Implementation:** Calls `new_v4` then `to_compact_string`.

## UUID v5 (Namespace SHA-1)

### new_v5 (a_namespace: ARRAY [NATURAL_8]; a_name: STRING_8): ARRAY [NATURAL_8]
Generate a deterministic UUID v5 from namespace and name.

**Algorithm:**
1. Concatenate namespace bytes + name bytes
2. Compute SHA-1 hash
3. Take first 16 bytes
4. Set version bits (5)
5. Set variant bits (RFC 4122)

**Determinism:** Same namespace + name always produces same UUID.

### new_v5_string (a_namespace: ARRAY [NATURAL_8]; a_name: STRING_8): STRING_8
Generate UUID v5 as hyphenated string.

### new_v5_dns (a_domain: STRING_8): STRING_8
Generate UUID v5 using DNS namespace.

**Example:** `new_v5_dns("www.example.com")`

### new_v5_url (a_url: STRING_8): STRING_8
Generate UUID v5 using URL namespace.

**Example:** `new_v5_url("https://example.com/page")`

## UUID v7 (Timestamp)

### new_v7: ARRAY [NATURAL_8]
Generate a new timestamp-based UUID v7 with monotonicity guarantee.

**Format:** tttttttt-tttt-7xxx-yxxx-xxxxxxxxxxxx

**Algorithm:**
1. Get 48-bit Unix millisecond timestamp
2. Add 12 random bits
3. Increment sequence counter if same millisecond
4. Set version bits (7)
5. Set variant bits (RFC 4122)

**Sortability:** UUIDs sort by creation time.

### new_v7_string: STRING_8
Generate UUID v7 as hyphenated string.

### new_v7_compact: STRING_8
Generate UUID v7 without hyphens.

## Formatting

### to_string (a_uuid: ARRAY [NATURAL_8]): STRING_8
Convert 16-byte UUID to hyphenated string.

**Format:** xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

### to_compact_string (a_uuid: ARRAY [NATURAL_8]): STRING_8
Convert 16-byte UUID to string without hyphens.

**Format:** xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

## Parsing

### from_string (a_string: STRING_8): ARRAY [NATURAL_8]
Parse UUID from string (with or without hyphens).

**Accepts:** Both hyphenated (36 chars) and compact (32 chars) formats.

## Validation

### is_valid_uuid (a_string: STRING_8): BOOLEAN
Check if string is valid hyphenated UUID.

**Rules:**
- Length = 36
- Hyphens at positions 9, 14, 19, 24
- All other characters hexadecimal

### is_valid_uuid_compact (a_string: STRING_8): BOOLEAN
Check if string is valid compact UUID.

**Rules:**
- Length = 32
- All characters hexadecimal

## Version Detection

### version (a_uuid: ARRAY [NATURAL_8]): INTEGER_32
Get version number from UUID bytes.

**Location:** Upper nibble of byte 7.

### version_from_string (a_string: STRING_8): INTEGER_32
Get version number from UUID string.
