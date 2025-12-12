note
	description: "Test application for simple_uuid"
	author: "Larry Rix"

class
	UUID_TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run tests.
		local
			tests: SIMPLE_UUID_TEST_SET
		do
			create tests
			print ("simple_uuid test runner%N")
			print ("========================%N%N")

			passed := 0
			failed := 0

			-- UUID v4 (Random)
			run_test (agent tests.test_new_v4_length, "test_new_v4_length")
			run_test (agent tests.test_new_v4_version, "test_new_v4_version")
			run_test (agent tests.test_new_v4_variant, "test_new_v4_variant")
			run_test (agent tests.test_new_v4_uniqueness, "test_new_v4_uniqueness")
			run_test (agent tests.test_new_v4_string_format, "test_new_v4_string_format")
			run_test (agent tests.test_new_v4_compact, "test_new_v4_compact")

			-- UUID v5 (Namespace SHA-1)
			run_test (agent tests.test_new_v5_format, "test_new_v5_format")
			run_test (agent tests.test_new_v5_version, "test_new_v5_version")
			run_test (agent tests.test_new_v5_variant, "test_new_v5_variant")
			run_test (agent tests.test_new_v5_deterministic, "test_new_v5_deterministic")
			run_test (agent tests.test_new_v5_different_names, "test_new_v5_different_names")
			run_test (agent tests.test_new_v5_different_namespaces, "test_new_v5_different_namespaces")
			run_test (agent tests.test_new_v5_dns_helper, "test_new_v5_dns_helper")
			run_test (agent tests.test_new_v5_url_helper, "test_new_v5_url_helper")
			run_test (agent tests.test_new_v5_known_vector, "test_new_v5_known_vector")
			run_test (agent tests.test_namespace_dns, "test_namespace_dns")
			run_test (agent tests.test_namespace_url, "test_namespace_url")

			-- UUID v7 (Timestamp)
			run_test (agent tests.test_new_v7_length, "test_new_v7_length")
			run_test (agent tests.test_new_v7_version, "test_new_v7_version")
			run_test (agent tests.test_new_v7_variant, "test_new_v7_variant")
			run_test (agent tests.test_new_v7_sortable, "test_new_v7_sortable")
			run_test (agent tests.test_new_v7_string_format, "test_new_v7_string_format")
			run_test (agent tests.test_new_v7_monotonicity, "test_new_v7_monotonicity")
			run_test (agent tests.test_new_v7_uniqueness, "test_new_v7_uniqueness")

			-- Formatting
			run_test (agent tests.test_to_string, "test_to_string")
			run_test (agent tests.test_to_compact_string, "test_to_compact_string")

			-- Parsing
			run_test (agent tests.test_from_string, "test_from_string")
			run_test (agent tests.test_from_compact_string, "test_from_compact_string")
			run_test (agent tests.test_from_known_uuid, "test_from_known_uuid")

			-- Validation
			run_test (agent tests.test_is_valid_uuid_correct, "test_is_valid_uuid_correct")
			run_test (agent tests.test_is_valid_uuid_uppercase, "test_is_valid_uuid_uppercase")
			run_test (agent tests.test_is_valid_uuid_wrong_length, "test_is_valid_uuid_wrong_length")
			run_test (agent tests.test_is_valid_uuid_wrong_hyphens, "test_is_valid_uuid_wrong_hyphens")
			run_test (agent tests.test_is_valid_uuid_invalid_char, "test_is_valid_uuid_invalid_char")
			run_test (agent tests.test_is_valid_uuid_compact, "test_is_valid_uuid_compact")

			-- Nil/Max UUID
			run_test (agent tests.test_nil_uuid, "test_nil_uuid")
			run_test (agent tests.test_nil_uuid_string, "test_nil_uuid_string")
			run_test (agent tests.test_is_nil_false_for_v4, "test_is_nil_false_for_v4")
			run_test (agent tests.test_max_uuid, "test_max_uuid")
			run_test (agent tests.test_max_uuid_string, "test_max_uuid_string")
			run_test (agent tests.test_is_max_false_for_v4, "test_is_max_false_for_v4")
			run_test (agent tests.test_is_max_false_for_nil, "test_is_max_false_for_nil")

			-- Version Detection
			run_test (agent tests.test_version_v4, "test_version_v4")
			run_test (agent tests.test_version_v7, "test_version_v7")
			run_test (agent tests.test_version_from_string, "test_version_from_string")

			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Implementation

	passed: INTEGER
	failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			print ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
