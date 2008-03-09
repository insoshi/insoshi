module DisplayHelper
  
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
end
    