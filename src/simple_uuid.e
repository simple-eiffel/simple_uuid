note
	description: "[
		Simple UUID - Lightweight UUID generation for Eiffel.

		Supports:
		- UUID v4 (random) - 122 random bits, most common format
		- UUID v7 (timestamp) - Sortable, millisecond precision timestamp

		UUID Format: xxxxxxxx-xxxx-Mxxx-Nxxx-xxxxxxxxxxxx
		- M = version (4 or 7)
		- N = variant (8, 9, a, or b for RFC 4122)

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
			-- Initialize the UUID generator.
		local
			l_time: TIME
			l_seed: INTEGER
		do
			create l_time.make_now
			l_seed := l_time.hour * 3600000 + l_time.minute * 60000 + l_time.second * 1000 + l_time.milli_second
			l_seed := l_seed.bit_xor ((l_time.seconds).to_integer_32)
			if l_seed <= 0 then
				l_seed := 1
			end
			create random.set_seed (l_seed)
			-- Prime the generator
			random.forth
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

feature -- UUID v7 (Timestamp)

	new_v7: ARRAY [NATURAL_8]
			-- Generate a new timestamp-based UUID v7.
			-- Format: tttttttt-tttt-7xxx-yxxx-xxxxxxxxxxxx
			-- First 48 bits are Unix milliseconds timestamp.
			-- Sortable by creation time.
		local
			l_timestamp: NATURAL_64
			i: INTEGER
		do
			create Result.make_filled (0, 1, 16)

			-- Get current Unix timestamp in milliseconds
			l_timestamp := unix_milliseconds

			-- First 6 bytes (48 bits) are timestamp, big-endian
			from
				i := 6
			until
				i < 1
			loop
				Result [i] := (l_timestamp & 0xFF).to_natural_8
				l_timestamp := l_timestamp |>> 8
				i := i - 1
			end

			-- Remaining bytes are random
			across 7 |..| 16 as idx loop
				Result [idx.item] := random_byte
			end

			-- Set version to 7 (0111 in high nibble of byte 7)
			Result [7] := (Result [7] & 0x0F) | 0x70

			-- Set variant to RFC 4122 (10xx in high bits of byte 9)
			Result [9] := (Result [9] & 0x3F) | 0x80
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

	nil_uuid: ARRAY [NATURAL_8]
			-- The nil UUID (all zeros).
		do
			create Result.make_filled (0, 1, 16)
		ensure
			correct_length: Result.count = 16
			is_nil: is_nil (Result)
		end

	nil_uuid_string: STRING = "00000000-0000-0000-0000-000000000000"
			-- The nil UUID as string.

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
			l_date: DATE_TIME
			l_epoch: DATE_TIME
			l_duration: DATE_TIME_DURATION
		do
			create l_date.make_now_utc
			create l_epoch.make (1970, 1, 1, 0, 0, 0)
			l_duration := l_date.relative_duration (l_epoch)
			Result := (l_duration.seconds_count * 1000 + l_date.time.milli_second).to_natural_64
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

feature -- Constants

	Hex_chars: STRING = "0123456789abcdef"
			-- Hexadecimal characters.

invariant
	random_exists: random /= Void

note
	copyright: "Copyright (c) 2024-2025, Larry Rix"
	license: "MIT License"

end
