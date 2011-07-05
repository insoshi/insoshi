module TabsHelper
  
  def tabs_for( *options, &block )
    raise ArgumentError, "Missing block" unless block_given?
    raw TabsHelper::TabsRenderer.new( *options, &block ).render
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
      @tabs << [ tab_id, tab_text, options, block, {:ajax => false} ]
    end
    
    def create_ajax( link, tab_text, options={})
      @tabs << [ link, tab_text, options, nil, {:ajax => true} ]
    end

    def render
      content_tag( :div, raw([render_tabs, render_bodies].join), { :id => :tabs }.merge( @options ) )
    end

    private # ---------------------------------------------------------------------------

    # XXX note "display: none" to prevent possible FOUC
    def render_tabs
      content_tag :ul, :style => "display: none;" do
        result = @tabs.collect do |tab|
          if tab[4][:ajax]
            content_tag( :li, link_to( content_tag( :span, raw(tab[1]) ), "#{tab[0]}" ) )
          else
            content_tag( :li, link_to( content_tag( :span, raw(tab[1]) ), "##{tab[0]}" ) )
          end
	end.join
	raw(result)
      end
    end
    
    def render_bodies
      @tabs.collect do |tab|
        if tab[4][:ajax]
          # there are no divs for ajaxed tabs
        else
          content_tag( :div, tab[2].merge( :id => tab[0] ), & tab[3])
        end
      end.join.to_s
    end
    
    def method_missing( *args, &block )
      @template.send( *args, &block )
    end
  end
end
