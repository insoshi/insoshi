module TabsHelper
  
  def tabs_for( *options, &block )
    raise ArgumentError, "Missing block" unless block_given?

    tabs = TabsHelper::TabsRenderer.new( *options, &block )
    tabs_html = tabs.render
    concat tabs_html
  end
  
  class TabsRenderer
    
    def initialize( options={}, &block )
      raise ArgumentError, "Missing block" unless block_given?

      @template = eval( 'self', block.binding )
      @options = options
      @tabs = []

      yield self
    end
    
    def create( tab_id, tab_text, options={}, &block )
      raise "Block needed for TabsRenderer#CREATE" unless block_given?
      @tabs << [ tab_id, tab_text, options, block ]
    end
    
    def render
      content_tag( :div, [render_tabs, render_bodies], { :id => :tabs }.merge( @options ) )
    end
    
    private #  ---------------------------------------------------------------------------
    
    def render_tabs
      content_tag :ul do
        @tabs.collect do |tab|
          content_tag( :li, link_to( content_tag( :span, tab[1] ), "##{tab[0]}" ) )
        end.join
      end
    end
    
    def  render_bodies
      @tabs.collect do |tab| 
        content_tag( :div, capture( &tab[3] ), tab[2].merge( :id => tab[0] ) ) 
      end.join.to_s
    end
    
    def method_missing( *args, &block )
      @template.send( *args, &block )
    end
    
  end

end
