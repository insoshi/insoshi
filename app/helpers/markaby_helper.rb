# Helpers written in Markaby.
# See http://redhanded.hobix.com/inspect/markabyForRails.html
# The plugin is broken in Rails 2.0.2.  Get a working plugin as follows:
# $ cd vendor/plugins
# $ git clone http://github.com/giraffesoft/markaby/tree/master
module MarkabyHelper
  
  # Return a raster of people images.
  # TODO: refactor this a bit
  def raster(people, options = {})
    columns = options[:num] || 4
    title   = options[:title] || ""
    image   = options[:image] || :icon
     markaby do
      div.module do
        table do
          tr do
            th(:colspan => columns) { title }
          end unless title.blank?
          people.collect_every(columns).each do |row|
            tr do
              row.each do |person| 
                td { link_to image_tag(person.send(image)), person }
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
    