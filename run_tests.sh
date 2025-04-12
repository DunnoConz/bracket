#!/bin/bash

# Run all Bracket tests

echo "Running all Bracket tests..."
echo ""

# Find all test files
TEST_FILES=$(find src/Tests -name "test_*.luau")

TOTAL=0
PASSED=0
FAILED=0

# Run each test file
for test_file in $TEST_FILES; do
    echo "Running: $test_file"
    TOTAL=$((TOTAL + 1))
    
    # Run the test with environment variable set
    export BRACKET_ENV=LUNE
    lune run "$test_file"
    unset BRACKET_ENV # Unset after run
    
    # Check result
    if [ $? -eq 0 ]; then
        echo "✅ PASSED: $test_file"
        PASSED=$((PASSED + 1))
    else
        echo "❌ FAILED: $test_file"
        FAILED=$((FAILED + 1))
    fi
    
    echo ""
done

# Print summary
echo "=== Test Summary ==="
echo "Total tests: $TOTAL"
echo "Passed: $PASSED"
echo "Failed: $FAILED"

# Set exit code
if [ $FAILED -gt 0 ]; then
    echo "❌ SOME TESTS FAILED"
    exit 1
else
    echo "✅ ALL TESTS PASSED"
    exit 0
fi 