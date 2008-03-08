# Helpers written in Markaby.
# See http://redhanded.hobix.com/inspect/markabyForRails.html
# The plugin is broken in Rails 2.0.2.  Get a working plugin as follows:
# $ cd vendor/plugins
# $ git clone http://github.com/giraffesoft/markaby/tree/master
# TODO: figure out how to make this not screw up the Git repository.
module MarkabyHelper
  
  # Raster a list of elements.
  # TODO: refactor this a bit
  def raster(list, options = {})
    columns = options[:num] || 4
    title   = options[:title] || ""
    markaby do
      div.module do
        table do
          tr do
            th(:colspan => columns) { title }
          end unless title.blank?
          list.collect_every(columns).each do |row|
            tr do
              row.each do |element| 
                td { element }
              end
            end
          end
        end
      end
    end
  end
  
  private
    
    # See http://railscasts.com/episodes/69
    def markaby(&block)
      Markaby::Builder.new({}, self, &block)
    end
end
    