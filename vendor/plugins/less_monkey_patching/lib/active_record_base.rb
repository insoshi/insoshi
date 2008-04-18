

class <<ActiveRecord::Base
  alias_method :[], :find
  
  
  def each options = :all, params = {}
    find(options, params).each{|i| yield i}
  end
  
  
  def find_with_defaults options = :all, params = {}
    find_without_defaults options, params
  end
  alias_method_chain :find, :defaults
  
end



class ActiveRecord::Base  


  
  
  def self.per_page
    $left_items_per_page
  end
  
  def dom_id(prefix='')
    display_id = new_record? ? "new" : id.to_s 
    prefix.to_s <<( '_') unless prefix.blank?
    prefix.to_s << "#{self.class.name.underscore}"
    prefix != :bare ? "#{prefix.to_s.underscore}_#{display_id}" : display_id
  end
  
  
  
  def to_controller
    self.class.to_s.underscore.downcase
  end
  
  def self.to_proper_noun
    self.class_name.underscore.titleize
  end
  
  def fix_numbers *attr_names
    attr_names.each do |attr_name|
      fixed = self.send("#{attr_name}_before_type_cast").to_s.gsub(/[\$,]/,'')
      self.attributes = {attr_name => fixed}
    end
  end
  
  
  def errors_combine other_errors
    other_errors.each do |at, msg|
      errors.add at, msg
    end
  end
  
  
  
  def errors_to_s
    errors.map do |e, m|
      "#{e.humanize unless e == "base"} #{m}\n"
    end.to_s.chomp
  end
  
end
