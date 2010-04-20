require 'paginator'

class Paginator

  # Total number of pages
  def number_of_pages_with_infinite
    number_of_pages_without_infinite unless infinite?
  end
  alias_method_chain :number_of_pages, :infinite
  
  # Is this an "infinite" paginator
  def infinite?
    @count.nil?
  end
  
  class Page
    # Checks to see if there's a page after this one
    def next_with_infinite?
      return true if @pager.infinite?
      next_without_infinite?
    end
    alias_method_chain :next?, :infinite
  end

end

