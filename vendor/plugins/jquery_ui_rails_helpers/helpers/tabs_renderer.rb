class TabsRenderer
  
  def initialize(template, options={})
    @template = template
    @options = options
    @tabs = []
  end
  
  def create(tab_id, tab_text, options={}, &block)
    raise "Block needed for TabsRenderer#CREATE" unless block_given?
    @tabs << [tab_id, tab_text, options, block]
  end
  
  def render
    content_tag(:div, (render_tabs + render_bodies), {:id => :tabs}.merge(@options))
  end
  
  private #  ---------------------------------------------------------------------------
  
  def render_tabs
    content_tag :ul do
      @tabs.collect do |tab|
        content_tag(:li, link_to(content_tag(:span, tab[1]), "##{tab[0]}") )
      end
    end
  end
  
  def  render_bodies
    @tabs.collect do |tab| 
      content_tag(:div, capture(&tab[3]), tab[2].merge(:id => tab[0])) 
    end.to_s
  end
  
  def method_missing(*args, &block)
    @template.send(*args, &block)
  end
  
end