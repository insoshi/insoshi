module DisplayHelper
  
  # Raster an array of elements.
  def raster(list, options = {})
    columns = options[:num] || N_COLUMNS
    title   = options[:title] || ""
    markaby do
      div.section do
        h1 { title } unless title.blank?
        table do
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
    