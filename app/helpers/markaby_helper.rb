# Helpers written in Markaby.
# See http://redhanded.hobix.com/inspect/markabyForRails.html
# The plugin is broken in Rails 2.0.2.  Get a working plugin as follows:
# $ cd vendor/plugins
# $ git clone http://github.com/giraffesoft/markaby/tree/master
module MarkabyHelper
  def raster(people, options = {})
    n = options[:num] || 4
    title = options[:title]
    image = options[:image] || :icon
     markaby do
      div.module do
        table do
          tr do
            th(:colspan => n) { title }
          end
          people.collect_every(n).each do |row|
            tr do
              row.each do |person| 
                td { image_tag person.send(image) }
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
    