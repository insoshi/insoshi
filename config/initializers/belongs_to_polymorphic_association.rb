# http://stackoverflow.com/questions/4522288/rails-3-activerecordrelation-random-associations-behavior
#
module ActiveRecord
  # = Active Record Belongs To Polymorphic Association
  module Associations
    class BelongsToPolymorphicAssociation < AssociationProxy #:nodoc:
      private
        def find_target
          return nil if association_class.nil?

          target =
            if @reflection.options[:conditions]
              association_class.select(@reflection.options[:select]).where(conditions).where(:id => @owner[@reflection.primary_key_name]).includes(@reflection.options[:include]).first
            else
              association_class.select(@reflection.options[:select]).where(:id => @owner[@reflection.primary_key_name]).includes(@reflection.options[:include]).first
            end
          set_inverse_instance(target, @owner)

          target
        end      
    end
  end
end
