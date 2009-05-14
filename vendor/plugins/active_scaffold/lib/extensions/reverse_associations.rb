module ActiveRecord
  module Reflection
    class AssociationReflection #:nodoc:
      def reverse_for?(klass)
        reverse_matches_for(klass).empty? ? false : true
      end

      attr_writer :reverse
      def reverse
        unless @reverse
          reverse_matches = reverse_matches_for(self.class_name.constantize)
          # grab first association, or make a wild guess
          @reverse = reverse_matches.empty? ? self.active_record.to_s.pluralize.underscore : reverse_matches.first.name
        end
        @reverse
      end

      protected

        def reverse_matches_for(klass)
          reverse_matches = []

          # stage 1 filter: collect associations that point back to this model and use the same primary_key_name
          klass.reflect_on_all_associations.each do |assoc|
            # skip over has_many :through associations
            next if assoc.options[:through]

            next unless assoc.options[:polymorphic] or assoc.class_name.constantize == self.active_record
            case [assoc.macro, self.macro].find_all{|m| m == :has_and_belongs_to_many}.length
              # if both are a habtm, then match them based on the join table
              when 2
              next unless assoc.options[:join_table] == self.options[:join_table]

              # if only one is a habtm, they do not match
              when 1
              next

              # otherwise, match them based on the primary_key_name
              when 0
              next unless assoc.primary_key_name.to_sym == self.primary_key_name.to_sym
            end

            reverse_matches << assoc
          end

          # stage 2 filter: name-based matching (association name vs self.active_record.to_s)
          reverse_matches.find_all do |assoc|
            self.active_record.to_s.underscore.include? assoc.name.to_s.pluralize.singularize
          end if reverse_matches.length > 1

          reverse_matches
        end

    end
  end
end