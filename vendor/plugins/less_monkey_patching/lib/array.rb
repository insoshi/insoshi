class Array



  def to_options(options = {})
    id = options[:id] || :id
    name = options[:name] || :name
    selected = options[:selected] || nil
    s = ''
    s << '<option></option>' if options[:include_blank]
    s << options[:extras] if options[:extras]
    each do |a|  
      case a.class.to_s
      when 'Array'
        s << "<option value=\"#{a[1]}\"#{' selected="selected"' if a[1] == selected}>#{a[0]}</option>\n"
      when 'String'
        s << "<option value=\"#{a}\"#{' selected="selected"' if a == selected}>#{a}</option>\n"
      else
        if a.is_a? ActiveRecord::Base
          s << "<option value=\"#{a.send id}\"#{' selected="selected"' if a.send(id) == selected}>#{a.send(name)}</option>\n"
        else
          raise "Type not supported: #{a.class}"
        end
      end
    end
    s
  end
  
  
  def to_select(object, method, options = {})
    s = ''
    clas = options[:class] || '' 
    options.symbolize_keys!
    options[:html].each_pair{|k,v| s << " #{k}=\"#{v}\""} if options[:html]
    <<-SEL
<select name="#{object}[#{method}]" id="#{object}_#{method}"#{s} class="#{clas}">
    #{self.to_options(options)}
</select>
SEL
  end
  
  
  def to_csv
    s = ''
    self.each do |a|
      next unless a.is_a? Array
      s << a.map{|i| i.to_s.gsub(',', '')}.join(',') << "\n"
    end
    s
  end
  
  
  
  def rand
     self[Object.send('rand', size)]
  end
  
  
  
  
  def else_each zero, &proc
    if size > 0
      each &proc
    else
      zero.call
    end
  end


  
  
end
