
# Provide a maximally flexible Markaby builder.
# For Markaby, see http://redhanded.hobix.com/inspect/markabyForRails.html
# The plugin is broken in Rails 2.0.2.  Get a working plugin as follows:
# $ cd vendor/plugins
# $ git clone http://github.com/giraffesoft/markaby/tree/master
# TODO: figure out how to make this not screw up the Git repository.
# See also http://railscasts.com/episodes/69
def markaby(&block)
  Markaby::Builder.new({}, self, &block)
end