note
	description: "[
		Simple UUID - Lightweight UUID generation for Eiffel.

		Supports:
		- UUID v4 (random) - 122 random bits, most common format
		- UUID v5 (namespace SHA-1) - Deterministic, name-based UUID
		- UUID v7 (timestamp) - Sortable, millisecond precision timestamp

		UUID Format: xxxxxxxx-xxxx-Mxxx-Nxxx-xxxxxxxxxxxx
		- M = version (4, 5, or 7)
		- N = variant (8, 9, a, or b for RFC 4122)

		Security Note:
		This implementation uses Eiffel's RANDOM class which is NOT cryptographically
		secure. The PRNG is seeded with multiple entropy sources (time, date,
		instance counter) to improve uniqueness, but this is NOT suitable for
		security-sensitive applications like session tokens or cryptographic keys.

		For security-critical UUIDs, consider:
		- Using operating system's secure random (/dev/urandom, CryptGenRandom)
		- Using a cryptographically secure PRNG library

		For general purpose identifiers (database keys, correlation IDs, etc.),
		this implementation provides sufficient randomness and uniqueness.

		Usage:
			create gen.make
			id := gen.new_v4           -- Random UUID
			id := gen.new_v7           -- Timestamp-based UUID
			id := gen.new_v4_string    -- As string directly
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Documentation", "src=../docs/index.html", "protocol=URI", "tag=documentation"
	EIS: "name=API Reference", "src=../docs/api/simple_uuid.html", "protocol=URI", "tag=api"
	EIS: "name=RFC 9562", "src=https://datatracker.ietf.org/doc/html/rfc9562", "protocol=URI", "tag=specification"

class
	SIMPLE_UUID

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize the UUID generator with enhanced entropy seeding.
		local
			l_dt: SIMPLE_DATE_TIME
			l_seed: INTEGER
			l_entropy: INTEGER_64
		do
			-- Gather entropy from timestamp (seconds since epoch)
			create l_dt.make_now
			l_entropy := l_dt.to_timestamp

			-- Add time-of-day variation
			l_entropy := l_entropy.bit_xor ((l_dt.time.hour * 3600 + l_dt.time.minute * 60 + l_dt.time.second).to_integer_64)

			-- Add date component for more entropy
			l_entropy := l_entropy.bit_xor ((l_dt.date.day * 100 + l_dt.date.month).to_integer_64)

			-- Add invocation counter for instances created in same second
			shared_counter.put (shared_counter.item + 1)
			l_entropy := l_entropy.bit_xor ((shared_counter.item.to_integer_64 |<< 16))

			-- Reduce to positive INTEGER seed
			l_seed := (l_entropy.bit_xor (l_entropy |>> 32)).to_integer_32.abs
			if l_seed <= 0 then
				l_seed := 1
			end

			create random.set_seed (l_seed)

			-- Prime the generator with multiple rounds
			across 1 |..| 10 as i loop
				random.forth
			end

			-- Initialize v7 monotonicity tracking
			last_v7_timestamp := 0
			v7_sequence := 0
		ensure
			random_created: random /= Void
		end

feature -- UUID v4 (Random)

	new_v4: ARRAY [NATURAL_8]
			-- Generate a new random UUID v4 (122 random bits).
			-- Format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
			-- where y is 8, 9, a, or b
		do
			create Result.make_filled (0, 1, 16)

			-- Fill with random bytes
			across 1 |..| 16 as i loop
				Result [i.item] := random_byte
			end

			-- Set version to 4 (0100 in high nibble of byte 7)
			Result [7] := (Result [7] & 0x0F) | 0x40

			-- Set variant to RFC 4122 (10xx in high bits of byte 9)
			Result [9] := (Result [9] & 0x3F) | 0x80
		ensure
			correct_length: Result.count = 16
			version_4: (Result [7] & 0xF0) = 0x40
			variant_rfc4122: (Result [9] & 0xC0) = 0x80
		end

	new_v4_string: STRING
			-- Generate a new random UUID v4 as hyphenated string.
		do
			Result := to_string (new_v4)
		ensure
			valid_format: is_valid_uuid (Result)
			correct_length: Result.count = 36
		end

	new_v4_compact: STRING
			-- Generate a new random UUID v4 without hyphens.
		do
			Result := to_compact_string (new_v4)
		ensure
			no_hyphens: not Result.has ('-')
			correct_length: Result.count = 32
		end

feature -- UUID v5 (Namespace SHA-1)

	new_v5 (a_namespace: ARRAY [NATURAL_8]; a_name: STRING): ARRAY [NATURAL_8]
			-- Generate a deterministic UUID v5 from `a_namespace' and `a_name'.
			-- Uses SHA-1 hash of namespace + name.
			-- Same namespace + name always produces same UUID.
		require
			valid_namespace: a_namespace.count = 16
			name_not_void: a_name /= Void
		local
			l_data: ARRAY [NATURAL_8]
			l_hash: ARRAY [NATURAL_8]
			i: INTEGER
		do
			-- Concatenate namespace UUID + name bytes
			create l_data.make_filled (0, 1, 16 + a_name.count)
			from i := 1 until i > 16 loop
				l_data [i] := a_namespace [i]
				i := i + 1
			variant
				17 - i
			end
			from i := 1 until i > a_name.count loop
				l_data [16 + i] := a_name [i].code.to_natural_8
				i := i + 1
			variant
				a_name.count + 1 - i
			end

			-- Hash with SHA-1 (produces 20 bytes)
			l_hash := sha1_bytes (l_data)

			-- Take first 16 bytes
			create Result.make_filled (0, 1, 16)
			from i := 1 until i > 16 loop
				Result [i] := l_hash [i]
				i := i + 1
			variant
				17 - i
			end

			-- Set version to 5 (0101 in high nibble of byte 7)
			Result [7] := (Result [7] & 0x0F) | 0x50

			-- Set variant to RFC 4122 (10xx in high bits of byte 9)
			Result [9] := (Result [9] & 0x3F) | 0x80
		ensure
			correct_length: Result.count = 16
			version_5: (Result [7] & 0xF0) = 0x50
			variant_rfc4122: (Result [9] & 0xC0) = 0x80
		end

	new_v5_string (a_namespace: ARRAY [NATURAL_8]; a_name: STRING): STRING
			-- Generate a deterministic UUID v5 as hyphenated string.
		require
			valid_namespace: a_namespace.count = 16
			name_not_void: a_name /= Void
		do
			Result := to_string (new_v5 (a_namespace, a_name))
		ensure
			valid_format: is_valid_uuid (Result)
			correct_length: Result.count = 36
		end

	new_v5_dns (a_domain: STRING): STRING
			-- Generate UUID v5 using DNS namespace for `a_domain'.
			-- Example: new_v5_dns("www.example.com")
		require
			domain_not_void: a_domain /= Void
			domain_not_empty: not a_domain.is_empty
		do
			Result := new_v5_string (Namespace_dns, a_domain)
		ensure
			valid_format: is_valid_uuid (Result)
		end

	new_v5_url (a_url: STRING): STRING
			-- Generate UUID v5 using URL namespace for `a_url'.
			-- Example: new_v5_url("https://www.example.com/page")
		require
			url_not_void: a_url /= Void
			url_not_empty: not a_url.is_empty
		do
			Result := new_v5_string (Namespace_url, a_url)
		ensure
			valid_format: is_valid_uuid (Result)
		end

feature -- Namespace UUIDs (RFC 4122)

	Namespace_dns: ARRAY [NATURAL_8]
			-- Namespace UUID for DNS names.
			-- 6ba7b810-9dad-11d1-80b4-00c04fd430c8
		once
			Result := from_string ("6ba7b810-9dad-11d1-80b4-00c04fd430c8")
		ensure
			correct_length: Result.count = 16
		end

	Namespace_url: ARRAY [NATURAL_8]
			-- Namespace UUID for URLs.
			-- 6ba7b811-9dad-11d1-80b4-00c04fd430c8
		once
			Result := from_string ("6ba7b811-9dad-11d1-80b4-00c04fd430c8")
		ensure
			correct_length: Result.count = 16
		end

	Namespace_oid: ARRAY [NATURAL_8]
			-- Namespace UUID for ISO OIDs.
			-- 6ba7b812-9dad-11d1-80b4-00c04fd430c8
		once
			Result := from_string ("6ba7b812-9dad-11d1-80b4-00c04fd430c8")
		ensure
			correct_length: Result.count = 16
		end

	Namespace_x500: ARRAY [NATURAL_8]
			-- Namespace UUID for X.500 DNs.
			-- 6ba7b814-9dad-11d1-80b4-00c04fd430c8
		once
			Result := from_string ("6ba7b814-9dad-11d1-80b4-00c04fd430c8")
		ensure
			correct_length: Result.count = 16
		end

feature -- UUID v7 (Timestamp)

	new_v7: ARRAY [NATURAL_8]
			-- Generate a new timestamp-based UUID v7 with monotonicity guarantee.
			-- Format: tttttttt-tttt-7xxx-yxxx-xxxxxxxxxxxx
			-- First 48 bits are Unix milliseconds timestamp.
			-- Includes sequence counter for UUIDs generated in same millisecond.
			-- Sortable by creation time.
		local
			l_timestamp: NATURAL_64
			i: INTEGER
			l_seq: NATURAL_16
			l_seq_high, l_seq_low: NATURAL_8
		do
			create Result.make_filled (0, 1, 16)

			-- Get current Unix timestamp in milliseconds
			l_timestamp := unix_milliseconds

			-- Handle monotonicity for same-millisecond generation
			if l_timestamp = last_v7_timestamp then
				-- Same millisecond, increment sequence
				v7_sequence := v7_sequence + 1
				if v7_sequence > 4095 then
					-- Sequence overflow - wait for next millisecond
					-- In practice, this is extremely unlikely (4096 UUIDs/ms)
					from
					until
						l_timestamp > last_v7_timestamp
					loop
						l_timestamp := unix_milliseconds
					end
					v7_sequence := 0
				end
			else
				-- New millisecond, reset sequence
				v7_sequence := 0
			end
			last_v7_timestamp := l_timestamp
			l_seq := v7_sequence

			-- First 6 bytes (48 bits) are timestamp, big-endian
			from
				i := 6
			until
				i < 1
			loop
				Result [i] := (l_timestamp & 0xFF).to_natural_8
				l_timestamp := l_timestamp |>> 8
				i := i - 1
			variant
				i
			end

			-- Byte 7: version (4 bits) + sequence high (4 bits)
			l_seq_high := ((l_seq |>> 8) & 0x0F).to_natural_8
			Result [7] := (0x70 | l_seq_high.to_integer_32).to_natural_8

			-- Byte 8: sequence low (8 bits)
			l_seq_low := (l_seq & 0xFF).to_natural_8
			Result [8] := l_seq_low

			-- Remaining bytes 9-16 are random
			across 9 |..| 16 as idx loop
				Result [idx.item] := random_byte
			end

			-- Set variant to RFC 4122 (10xx in high bits of byte 9)
			Result [9] := ((Result [9] & 0x3F) | 0x80).to_natural_8
		ensure
			correct_length: Result.count = 16
			version_7: (Result [7] & 0xF0) = 0x70
			variant_rfc4122: (Result [9] & 0xC0) = 0x80
		end

	new_v7_string: STRING
			-- Generate a new timestamp-based UUID v7 as string.
		do
			Result := to_string (new_v7)
		ensure
			valid_format: is_valid_uuid (Result)
			correct_length: Result.count = 36
		end

	new_v7_compact: STRING
			-- Generate a new timestamp-based UUID v7 without hyphens.
		do
			Result := to_compact_string (new_v7)
		ensure
			no_hyphens: not Result.has ('-')
			correct_length: Result.count = 32
		end

feature -- Formatting

	to_string (a_uuid: ARRAY [NATURAL_8]): STRING
			-- Convert UUID bytes to hyphenated string.
			-- Format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
		require
			valid_uuid: a_uuid.count = 16
		do
			create Result.make (36)

			-- Bytes 1-4
			Result.append (byte_to_hex (a_uuid [1]))
			Result.append (byte_to_hex (a_uuid [2]))
			Result.append (byte_to_hex (a_uuid [3]))
			Result.append (byte_to_hex (a_uuid [4]))
			Result.append_character ('-')

			-- Bytes 5-6
			Result.append (byte_to_hex (a_uuid [5]))
			Result.append (byte_to_hex (a_uuid [6]))
			Result.append_character ('-')

			-- Bytes 7-8
			Result.append (byte_to_hex (a_uuid [7]))
			Result.append (byte_to_hex (a_uuid [8]))
			Result.append_character ('-')

			-- Bytes 9-10
			Result.append (byte_to_hex (a_uuid [9]))
			Result.append (byte_to_hex (a_uuid [10]))
			Result.append_character ('-')

			-- Bytes 11-16
			Result.append (byte_to_hex (a_uuid [11]))
			Result.append (byte_to_hex (a_uuid [12]))
			Result.append (byte_to_hex (a_uuid [13]))
			Result.append (byte_to_hex (a_uuid [14]))
			Result.append (byte_to_hex (a_uuid [15]))
			Result.append (byte_to_hex (a_uuid [16]))
		ensure
			correct_format: Result.count = 36
			has_hyphens: Result.occurrences ('-') = 4
		end

	to_compact_string (a_uuid: ARRAY [NATURAL_8]): STRING
			-- Convert UUID bytes to string without hyphens.
		require
			valid_uuid: a_uuid.count = 16
		do
			create Result.make (32)
			across a_uuid as b loop
				Result.append (byte_to_hex (b.item))
			end
		ensure
			correct_length: Result.count = 32
			no_hyphens: not Result.has ('-')
		end

feature -- Parsing

	from_string (a_string: STRING): ARRAY [NATURAL_8]
			-- Parse UUID from string (with or without hyphens).
		require
			valid_input: is_valid_uuid (a_string) or is_valid_uuid_compact (a_string)
		local
			l_clean: STRING
			i, j: INTEGER
		do
			-- Remove hyphens
			l_clean := a_string.twin
			l_clean.replace_substring_all ("-", "")
			l_clean.to_lower

			create Result.make_filled (0, 1, 16)
			from
				i := 1
				j := 1
			until
				i > 32
			loop
				Result [j] := hex_to_byte (l_clean.substring (i, i + 1))
				i := i + 2
				j := j + 1
			variant
				33 - i
			end
		ensure
			correct_length: Result.count = 16
		end

feature -- Validation

	is_valid_uuid (a_string: STRING): BOOLEAN
			-- Is `a_string' a valid hyphenated UUID?
			-- Format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
		require
			string_not_void: a_string /= Void
		local
			i: INTEGER
			c: CHARACTER
		do
			if a_string.count = 36 then
				Result := True
				from
					i := 1
				until
					i > 36 or not Result
				loop
					c := a_string [i].as_lower
					if i = 9 or i = 14 or i = 19 or i = 24 then
						Result := c = '-'
					else
						Result := Hex_chars.has (c)
					end
					i := i + 1
				variant
					37 - i
				end
			end
		end

	is_valid_uuid_compact (a_string: STRING): BOOLEAN
			-- Is `a_string' a valid compact UUID (no hyphens)?
		require
			string_not_void: a_string /= Void
		local
			i: INTEGER
		do
			if a_string.count = 32 then
				Result := True
				from
					i := 1
				until
					i > 32 or not Result
				loop
					Result := Hex_chars.has (a_string [i].as_lower)
					i := i + 1
				variant
					33 - i
				end
			end
		end

feature -- Comparison

	is_nil (a_uuid: ARRAY [NATURAL_8]): BOOLEAN
			-- Is `a_uuid' the nil UUID (all zeros)?
		require
			valid_uuid: a_uuid.count = 16
		do
			Result := across a_uuid as b all b.item = 0 end
		end

	is_max (a_uuid: ARRAY [NATURAL_8]): BOOLEAN
			-- Is `a_uuid' the max UUID (all ones)?
		require
			valid_uuid: a_uuid.count = 16
		do
			Result := across a_uuid as b all b.item = 0xFF end
		end

	nil_uuid: ARRAY [NATURAL_8]
			-- The nil UUID (all zeros).
		do
			create Result.make_filled (0, 1, 16)
		ensure
			correct_length: Result.count = 16
			is_nil: is_nil (Result)
		end

	max_uuid: ARRAY [NATURAL_8]
			-- The max UUID (all ones) per RFC 9562.
		do
			create Result.make_filled (0xFF, 1, 16)
		ensure
			correct_length: Result.count = 16
			is_max: is_max (Result)
		end

	nil_uuid_string: STRING = "00000000-0000-0000-0000-000000000000"
			-- The nil UUID as string.

	max_uuid_string: STRING = "ffffffff-ffff-ffff-ffff-ffffffffffff"
			-- The max UUID as string (RFC 9562).

feature -- Version Detection

	version (a_uuid: ARRAY [NATURAL_8]): INTEGER
			-- Get the version number of `a_uuid'.
		require
			valid_uuid: a_uuid.count = 16
		do
			Result := (a_uuid [7] |>> 4).to_integer_32
		ensure
			valid_version: Result >= 0 and Result <= 15
		end

	version_from_string (a_string: STRING): INTEGER
			-- Get the version number from UUID string.
		require
			valid_uuid: is_valid_uuid (a_string) or is_valid_uuid_compact (a_string)
		do
			Result := version (from_string (a_string))
		ensure
			valid_version: Result >= 0 and Result <= 15
		end

feature {NONE} -- Implementation

	random: RANDOM
			-- Random number generator.
			-- Note: This is Eiffel's standard PRNG, not cryptographically secure.

	shared_counter: CELL [INTEGER_32]
			-- Shared counter across all instances for entropy in same-millisecond creation.
		once
			create Result.put (0)
		end

	last_v7_timestamp: NATURAL_64
			-- Last timestamp used for v7 UUID generation.

	v7_sequence: NATURAL_16
			-- Sequence counter for v7 UUIDs in same millisecond.
			-- Provides monotonicity guarantee.

	random_byte: NATURAL_8
			-- Generate a random byte.
		do
			random.forth
			Result := (random.item \\ 256).to_natural_8
		ensure
			valid_byte: Result >= 0 and Result <= 255
		end

	unix_milliseconds: NATURAL_64
			-- Current Unix timestamp in milliseconds.
		local
			l_now: SIMPLE_DATE_TIME
		do
			create l_now.make_now
			Result := (l_now.to_timestamp * 1000).to_natural_64
		ensure
			positive_timestamp: Result > 0
		end
	byte_to_hex (a_byte: NATURAL_8): STRING
			-- Convert byte to 2-character hex string.
		do
			create Result.make (2)
			Result.append_character (Hex_chars [(a_byte |>> 4).to_integer_32 + 1])
			Result.append_character (Hex_chars [(a_byte & 0x0F).to_integer_32 + 1])
		ensure
			correct_length: Result.count = 2
		end

	hex_to_byte (a_hex: STRING): NATURAL_8
			-- Convert 2-character hex string to byte.
		require
			correct_length: a_hex.count = 2
		local
			high, low: INTEGER
		do
			high := Hex_chars.index_of (a_hex [1].as_lower, 1) - 1
			low := Hex_chars.index_of (a_hex [2].as_lower, 1) - 1
			if high >= 0 and low >= 0 then
				Result := ((high |<< 4) | low).to_natural_8
			end
		end

feature {NONE} -- SHA-1 Implementation (for UUID v5)

	sha1_bytes (a_data: ARRAY [NATURAL_8]): ARRAY [NATURAL_8]
			-- Compute SHA-1 hash of `a_data' and return as 20 bytes.
		local
			l_padded: ARRAY [NATURAL_8]
			h0, h1, h2, h3, h4: NATURAL_32
			a, b, c, d, e: NATURAL_32
			f, k, temp: NATURAL_32
			w: ARRAY [NATURAL_32]
			i, j, chunk_start: INTEGER
		do
			-- Pad message
			l_padded := sha1_pad (a_data)

			-- Initialize hash values
			h0 := 0x67452301
			h1 := 0xEFCDAB89
			h2 := 0x98BADCFE
			h3 := 0x10325476
			h4 := 0xC3D2E1F0

			-- Process each 512-bit (64-byte) chunk
			create w.make_filled (0, 1, 80)
			from
				chunk_start := 1
			until
				chunk_start > l_padded.count
			loop
				-- Copy chunk into first 16 words (big-endian)
				from i := 1 until i > 16 loop
					j := chunk_start + (i - 1) * 4
					w [i] := (l_padded [j].to_natural_32 |<< 24) |
							 (l_padded [j + 1].to_natural_32 |<< 16) |
							 (l_padded [j + 2].to_natural_32 |<< 8) |
							 l_padded [j + 3].to_natural_32
					i := i + 1
				variant
					17 - i
				end

				-- Extend first 16 words into remaining 64 words
				from i := 17 until i > 80 loop
					w [i] := rotl32 (w [i - 3].bit_xor (w [i - 8]).bit_xor (w [i - 14]).bit_xor (w [i - 16]), 1)
					i := i + 1
				variant
					81 - i
				end

				-- Initialize working variables
				a := h0; b := h1; c := h2; d := h3; e := h4

				-- Main compression loop (80 rounds)
				from i := 1 until i > 80 loop
					if i <= 20 then
						f := (b & c) | (b.bit_not & d)
						k := 0x5A827999
					elseif i <= 40 then
						f := b.bit_xor (c).bit_xor (d)
						k := 0x6ED9EBA1
					elseif i <= 60 then
						f := (b & c) | (b & d) | (c & d)
						k := 0x8F1BBCDC
					else
						f := b.bit_xor (c).bit_xor (d)
						k := 0xCA62C1D6
					end

					temp := rotl32 (a, 5) + f + e + k + w [i]
					e := d
					d := c
					c := rotl32 (b, 30)
					b := a
					a := temp
					i := i + 1
				variant
					81 - i
				end

				-- Add compressed chunk to hash values
				h0 := h0 + a; h1 := h1 + b; h2 := h2 + c
				h3 := h3 + d; h4 := h4 + e

				chunk_start := chunk_start + 64
			variant
				l_padded.count - chunk_start + 64
			end

			-- Produce final hash value (big-endian, 20 bytes)
			create Result.make_filled (0, 1, 20)
			put_nat32_be (Result, 1, h0)
			put_nat32_be (Result, 5, h1)
			put_nat32_be (Result, 9, h2)
			put_nat32_be (Result, 13, h3)
			put_nat32_be (Result, 17, h4)
		ensure
			correct_length: Result.count = 20
		end

	sha1_pad (a_message: ARRAY [NATURAL_8]): ARRAY [NATURAL_8]
			-- Pad message according to SHA-1 spec.
		local
			l_len: INTEGER_64
			l_padded_len: INTEGER
			i: INTEGER
			l_result: ARRAYED_LIST [NATURAL_8]
		do
			l_len := a_message.count.to_integer_64 * 8 -- length in bits

			-- Calculate padded length (multiple of 512 bits = 64 bytes)
			l_padded_len := a_message.count + 1 + 8 -- message + 0x80 + 64-bit length
			if l_padded_len \\ 64 /= 0 then
				l_padded_len := l_padded_len + (64 - l_padded_len \\ 64)
			end

			create l_result.make (l_padded_len)

			-- Copy original message
			across a_message as b loop
				l_result.extend (b.item)
			end

			-- Append bit '1' (0x80)
			l_result.extend (0x80)

			-- Append zeros until 8 bytes from end
			from until l_result.count = l_padded_len - 8 loop
				l_result.extend (0)
			variant
				l_padded_len - 8 - l_result.count
			end

			-- Append original length in bits as 64-bit big-endian
			from i := 56 until i < 0 loop
				l_result.extend ((l_len |>> i).to_natural_8 & 0xFF)
				i := i - 8
			variant
				i + 8
			end

			create Result.make_from_array (l_result.to_array)
		ensure
			multiple_of_64: Result.count \\ 64 = 0
		end

	rotl32 (a_value: NATURAL_32; a_shift: INTEGER): NATURAL_32
			-- Rotate left 32-bit.
		require
			valid_shift: a_shift >= 0 and a_shift < 32
		do
			Result := (a_value |<< a_shift) | (a_value |>> (32 - a_shift))
		end

	put_nat32_be (a_array: ARRAY [NATURAL_8]; a_index: INTEGER; a_value: NATURAL_32)
			-- Put 32-bit value in big-endian order.
		require
			valid_index: a_index >= 1 and a_index + 3 <= a_array.count
		do
			a_array [a_index] := (a_value |>> 24).to_natural_8
			a_array [a_index + 1] := (a_value |>> 16).to_natural_8
			a_array [a_index + 2] := (a_value |>> 8).to_natural_8
			a_array [a_index + 3] := a_value.to_natural_8
		end

feature -- Constants

	Hex_chars: STRING = "0123456789abcdef"
			-- Hexadecimal characters.

invariant
	random_exists: random /= Void

note
	copyright: "Copyright (c) 2024-2025, Larry Rix"
	license: "MIT License"

end
