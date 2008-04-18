module Less
  module Dates
    module Methods
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def less_dates(*attr_names)
          validates_each(attr_names) do |record, attr_name, value|
            if value.nil?
              record.errors.add(attr_name, "is not a valid date")
            else
              converted_value = value.to_formatted_date(yield(record))
              if converted_value.nil?
                record.errors.add(attr_name, "is not a valid date")
              else
                record.attributes[attr_name.to_s] = converted_value
              end
            end
          end
        end
      end
    end
  end
end
