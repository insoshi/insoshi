# Database strings typically can't be longer than 255.
MAX_STRING_LENGTH = 255
# This is arbitrary, but "small".
SMALL_STRING_LENGTH = 40
# This is arbitrary, but "big".
MAX_TEXT_LENGTH = 1000
# Some text fields should allow less
SMALL_TEXT_LENGTH = 300

# Ferret adds a significant overhead to tests, so disable it by default.
# Set this to true to run the tests with Ferret enabled.
FERRET_IN_TESTS = false

# Ferret runs if test is not true, or (if test true) if ferret is true.
def ferret?
  !test? or FERRET_IN_TESTS
end

# The number of raster colums.
N_COLUMNS = 4
# The number of raster results per page.
RASTER_PER_PAGE = 3 * N_COLUMNS