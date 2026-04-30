#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "======================================"
echo "Running Unit Tests"
echo "======================================"
flutter test

echo ""
echo "======================================"
echo "Running Integration Tests"
echo "======================================"

# Note: A device or simulator must be running to execute integration tests
flutter test integration_test/plugin_integration_test.dart

echo ""
echo "======================================"
echo "All tests completed successfully!"
echo "======================================"
