# Column sizes
FULL = 20
LEFT = 14
RIGHT = 6

# Database strings typically can't be longer than 255.
MAX_STRING_LENGTH = 255
MEDIUM_STRING_LENGTH = 70
SMALL_STRING_LENGTH = 40

MAX_TEXT_LENGTH = 1000
MEDIUM_TEXT_LENGTH = 500
SMALL_TEXT_LENGTH = 300

# Search adds a significant overhead to tests, so disable it by default.
# Set this to true to run the tests with search enabled.
SEARCH_IN_TESTS = true

# Search runs if test is not true, or (if test true) if search is true.
def search?
  !test? or SEARCH_IN_TESTS
end

# The number of raster colums.
N_COLUMNS = 4
# The number of raster results per page.
RASTER_PER_PAGE = 3 * N_COLUMNS
