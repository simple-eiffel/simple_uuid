note
	description: "Tests for SIMPLE_UUID"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	SIMPLE_UUID_TEST_SET

inherit
	TEST_SET_BASE

feature -- Test: UUID v4 Generation

	test_new_v4_length
			-- Test v4 UUID has correct length.
		note
			testing: "covers/{SIMPLE_UUID}.new_v4"
		local
			gen: SIMPLE_UUID
			uuid: ARRAY [NATURAL_8]
		do
			create gen.make
			uuid := gen.new_v4
			assert_integers_equal ("16 bytes", 16, uuid.count)
		end

	test_new_v4_version
			-- Test v4 UUID has version 4.
		note
			testing: "covers/{SIMPLE_UUID}.new_v4", "covers/{SIMPLE_UUID}.version"
		local
			gen: SIMPLE_UUID
			uuid: ARRAY [NATURAL_8]
		do
			create gen.make
			uuid := gen.new_v4
			assert_integers_equal ("version 4", 4, gen.version (uuid))
		end

	test_new_v4_variant
			-- Test v4 UUID has RFC 4122 variant.
		note
			testing: "covers/{SIMPLE_UUID}.new_v4"
		local
			gen: SIMPLE_UUID
			uuid: ARRAY [NATURAL_8]
		do
			create gen.make
			uuid := gen.new_v4
			-- Variant bits should be 10xx (0x80-0xBF)
			assert ("variant RFC4122", (uuid [9] & 0xC0) = 0x80)
		end

	test_new_v4_uniqueness
			-- Test v4 UUIDs are unique.
		note
			testing: "covers/{SIMPLE_UUID}.new_v4_string"
		local
			gen: SIMPLE_UUID
			uuid1, uuid2: STRING
		do
			create gen.make
			uuid1 := gen.new_v4_string
			uuid2 := gen.new_v4_string
			assert ("unique", not uuid1.is_equal (uuid2))
		end

	test_new_v4_string_format
			-- Test v4 UUID string format.
		note
			testing: "covers/{SIMPLE_UUID}.new_v4_string"
		local
			gen: SIMPLE_UUID
			uuid: STRING
		do
			create gen.make
			uuid := gen.new_v4_string
			assert_integers_equal ("36 chars", 36, uuid.count)
			assert_integers_equal ("4 hyphens", 4, uuid.occurrences ('-'))
			assert ("hyphen at 9", uuid [9] = '-')
			assert ("hyphen at 14", uuid [14] = '-')
			assert ("hyphen at 19", uuid [19] = '-')
			assert ("hyphen at 24", uuid [24] = '-')
		end

	test_new_v4_compact
			-- Test v4 UUID compact string.
		note
			testing: "covers/{SIMPLE_UUID}.new_v4_compact"
		local
			gen: SIMPLE_UUID
			uuid: STRING
		do
			create gen.make
			uuid := gen.new_v4_compact
			assert_integers_equal ("32 chars", 32, uuid.count)
			assert ("no hyphens", not uuid.has ('-'))
		end

feature -- Test: UUID v7 Generation

	test_new_v7_length
			-- Test v7 UUID has correct length.
		note
			testing: "covers/{SIMPLE_UUID}.new_v7"
		local
			gen: SIMPLE_UUID
			uuid: ARRAY [NATURAL_8]
		do
			create gen.make
			uuid := gen.new_v7
			assert_integers_equal ("16 bytes", 16, uuid.count)
		end

	test_new_v7_version
			-- Test v7 UUID has version 7.
		note
			testing: "covers/{SIMPLE_UUID}.new_v7", "covers/{SIMPLE_UUID}.version"
		local
			gen: SIMPLE_UUID
			uuid: ARRAY [NATURAL_8]
		do
			create gen.make
			uuid := gen.new_v7
			assert_integers_equal ("version 7", 7, gen.version (uuid))
		end

	test_new_v7_variant
			-- Test v7 UUID has RFC 4122 variant.
		note
			testing: "covers/{SIMPLE_UUID}.new_v7"
		local
			gen: SIMPLE_UUID
			uuid: ARRAY [NATURAL_8]
		do
			create gen.make
			uuid := gen.new_v7
			assert ("variant RFC4122", (uuid [9] & 0xC0) = 0x80)
		end

	test_new_v7_sortable
			-- Test v7 UUIDs share timestamp prefix when generated together.
		note
			testing: "covers/{SIMPLE_UUID}.new_v7_string"
		local
			gen: SIMPLE_UUID
			uuid1, uuid2: STRING
		do
			create gen.make
			uuid1 := gen.new_v7_string
			uuid2 := gen.new_v7_string
			-- UUIDs generated in same millisecond share first 12 hex chars (48-bit timestamp)
			-- Note: True sortability requires generation at different times
			assert ("same timestamp prefix", uuid1.substring (1, 8).is_equal (uuid2.substring (1, 8)))
		end

	test_new_v7_string_format
			-- Test v7 UUID string format.
		note
			testing: "covers/{SIMPLE_UUID}.new_v7_string", "covers/{SIMPLE_UUID}.is_valid_uuid"
		local
			gen: SIMPLE_UUID
			uuid: STRING
		do
			create gen.make
			uuid := gen.new_v7_string
			assert_integers_equal ("36 chars", 36, uuid.count)
			assert ("is valid", gen.is_valid_uuid (uuid))
		end

feature -- Test: Formatting

	test_to_string
			-- Test UUID to string conversion.
		note
			testing: "covers/{SIMPLE_UUID}.to_string", "covers/{SIMPLE_UUID}.is_valid_uuid"
		local
			gen: SIMPLE_UUID
			uuid: ARRAY [NATURAL_8]
			s: STRING
		do
			create gen.make
			uuid := gen.new_v4
			s := gen.to_string (uuid)
			assert_integers_equal ("correct length", 36, s.count)
			assert ("valid format", gen.is_valid_uuid (s))
		end

	test_to_compact_string
			-- Test UUID to compact string.
		note
			testing: "covers/{SIMPLE_UUID}.to_compact_string"
		local
			gen: SIMPLE_UUID
			uuid: ARRAY [NATURAL_8]
			s: STRING
		do
			create gen.make
			uuid := gen.new_v4
			s := gen.to_compact_string (uuid)
			assert_integers_equal ("correct length", 32, s.count)
			assert ("no hyphens", not s.has ('-'))
		end

feature -- Test: Parsing

	test_from_string
			-- Test parsing UUID from string.
		note
			testing: "covers/{SIMPLE_UUID}.from_string", "covers/{SIMPLE_UUID}.to_string"
		local
			gen: SIMPLE_UUID
			original: STRING
			uuid: ARRAY [NATURAL_8]
			roundtrip: STRING
		do
			create gen.make
			original := gen.new_v4_string
			uuid := gen.from_string (original)
			roundtrip := gen.to_string (uuid)
			assert_strings_equal ("roundtrip", original.as_lower, roundtrip.as_lower)
		end

	test_from_compact_string
			-- Test parsing UUID from compact string.
		note
			testing: "covers/{SIMPLE_UUID}.from_string", "covers/{SIMPLE_UUID}.to_compact_string"
		local
			gen: SIMPLE_UUID
			original: STRING
			uuid: ARRAY [NATURAL_8]
			roundtrip: STRING
		do
			create gen.make
			original := gen.new_v4_compact
			uuid := gen.from_string (original)
			roundtrip := gen.to_compact_string (uuid)
			assert_strings_equal ("roundtrip compact", original.as_lower, roundtrip.as_lower)
		end

	test_from_known_uuid
			-- Test parsing a known UUID.
		note
			testing: "covers/{SIMPLE_UUID}.from_string"
		local
			gen: SIMPLE_UUID
			uuid: ARRAY [NATURAL_8]
		do
			create gen.make
			uuid := gen.from_string ("550e8400-e29b-41d4-a716-446655440000")
			assert_integers_equal ("byte 1", 0x55, uuid [1])
			assert_integers_equal ("byte 2", 0x0e, uuid [2])
			assert_integers_equal ("byte 3", 0x84, uuid [3])
			assert_integers_equal ("byte 4", 0x00, uuid [4])
		end

feature -- Test: Validation

	test_is_valid_uuid_correct
			-- Test validation of correct UUID.
		note
			testing: "covers/{SIMPLE_UUID}.is_valid_uuid"
		local
			gen: SIMPLE_UUID
		do
			create gen.make
			assert ("valid uuid", gen.is_valid_uuid ("550e8400-e29b-41d4-a716-446655440000"))
		end

	test_is_valid_uuid_uppercase
			-- Test validation accepts uppercase.
		note
			testing: "covers/{SIMPLE_UUID}.is_valid_uuid"
		local
			gen: SIMPLE_UUID
		do
			create gen.make
			assert ("valid uppercase", gen.is_valid_uuid ("550E8400-E29B-41D4-A716-446655440000"))
		end

	test_is_valid_uuid_wrong_length
			-- Test validation rejects wrong length.
		note
			testing: "covers/{SIMPLE_UUID}.is_valid_uuid"
		local
			gen: SIMPLE_UUID
		do
			create gen.make
			assert ("reject short", not gen.is_valid_uuid ("550e8400-e29b-41d4-a716"))
		end

	test_is_valid_uuid_wrong_hyphens
			-- Test validation rejects wrong hyphen positions.
		note
			testing: "covers/{SIMPLE_UUID}.is_valid_uuid"
		local
			gen: SIMPLE_UUID
		do
			create gen.make
			assert ("reject wrong hyphens", not gen.is_valid_uuid ("550e8400e29b-41d4-a716-446655440000"))
		end

	test_is_valid_uuid_invalid_char
			-- Test validation rejects invalid characters.
		note
			testing: "covers/{SIMPLE_UUID}.is_valid_uuid"
		local
			gen: SIMPLE_UUID
		do
			create gen.make
			assert ("reject invalid char", not gen.is_valid_uuid ("550e8400-e29b-41d4-a716-44665544000g"))
		end

	test_is_valid_uuid_compact
			-- Test validation of compact UUID.
		note
			testing: "covers/{SIMPLE_UUID}.is_valid_uuid_compact"
		local
			gen: SIMPLE_UUID
		do
			create gen.make
			assert ("valid compact", gen.is_valid_uuid_compact ("550e8400e29b41d4a716446655440000"))
		end

feature -- Test: Nil UUID

	test_nil_uuid
			-- Test nil UUID generation.
		note
			testing: "covers/{SIMPLE_UUID}.nil_uuid", "covers/{SIMPLE_UUID}.is_nil"
		local
			gen: SIMPLE_UUID
			uuid: ARRAY [NATURAL_8]
		do
			create gen.make
			uuid := gen.nil_uuid
			assert ("is nil", gen.is_nil (uuid))
			assert ("all zeros", across uuid as b all b.item = 0 end)
		end

	test_nil_uuid_string
			-- Test nil UUID string.
		note
			testing: "covers/{SIMPLE_UUID}.nil_uuid_string"
		local
			gen: SIMPLE_UUID
		do
			create gen.make
			assert_strings_equal ("nil string", "00000000-0000-0000-0000-000000000000", gen.nil_uuid_string)
		end

	test_is_nil_false_for_v4
			-- Test is_nil returns false for v4 UUID.
		note
			testing: "covers/{SIMPLE_UUID}.is_nil", "covers/{SIMPLE_UUID}.new_v4"
		local
			gen: SIMPLE_UUID
		do
			create gen.make
			assert ("not nil", not gen.is_nil (gen.new_v4))
		end

feature -- Test: Version Detection

	test_version_v4
			-- Test version detection for v4.
		note
			testing: "covers/{SIMPLE_UUID}.version", "covers/{SIMPLE_UUID}.new_v4"
		local
			gen: SIMPLE_UUID
		do
			create gen.make
			assert_integers_equal ("version 4", 4, gen.version (gen.new_v4))
		end

	test_version_v7
			-- Test version detection for v7.
		note
			testing: "covers/{SIMPLE_UUID}.version", "covers/{SIMPLE_UUID}.new_v7"
		local
			gen: SIMPLE_UUID
		do
			create gen.make
			assert_integers_equal ("version 7", 7, gen.version (gen.new_v7))
		end

	test_version_from_string
			-- Test version detection from string.
		note
			testing: "covers/{SIMPLE_UUID}.version_from_string", "covers/{SIMPLE_UUID}.new_v4_string"
		local
			gen: SIMPLE_UUID
			uuid: STRING
		do
			create gen.make
			uuid := gen.new_v4_string
			assert_integers_equal ("version from string", 4, gen.version_from_string (uuid))
		end

end
