# Database strings typically can't be longer than 255.
MAX_STRING_LENGTH = 255

# This is arbitrary, but "big".
MAX_TEXT_LENGTH = 1000

# Ferret adds a significant overhead to tests, so disable it by default.
# Set this to true to run the tests with Ferret enabled.
FERRET_IN_TESTS = false