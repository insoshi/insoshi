require 'forwardable'

class Paginator
  
  VERSION = '1.0.9'

  class ArgumentError < ::ArgumentError; end
  class MissingCountError < ArgumentError; end
  class MissingSelectError < ArgumentError; end  
  
  attr_reader :per_page, :count 
  
  # Instantiate a new Paginator object
  #
  # Provide:
  # * A total count of the number of objects to paginate
  # * The number of objects in each page
  # * A block that returns the array of items
  #   * The block is passed the item offset 
  #     (and the number of items to show per page, for
  #     convenience, if the arity is 2)
  def initialize(count, per_page, &select)
    @count, @per_page = count, per_page
    unless select
      raise MissingSelectError, "Must provide block to select data for each page"
    end
    @select = select
  end
  
  # Total number of pages
  def number_of_pages
     (@count / @per_page).to_i + (@count % @per_page > 0 ? 1 : 0)
  end
  
  # First page object
  def first
    page 1
  end
  
  # Last page object
  def last
    page number_of_pages
  end
  
  # Iterate through pages
  def each
    each_with_index do |item, index|
      yield item
    end
  end
  
  # Iterate through pages with indices
  def each_with_index
    1.upto(number_of_pages) do |number|
      yield(page(number), number - 1)
    end
  end
  
  # Retrieve page object by number
  def page(number)
    number = (n = number.to_i) > 0 ? n : 1
    Page.new(self, number, lambda { 
      offset = (number - 1) * @per_page
      args = [offset]
      args << @per_page if @select.arity == 2
      @select.call(*args)
    })
  end
  
  # Page object
  #
  # Retrieves items for a page and provides metadata about the position
  # of the page in the paginator
  class Page
    
    extend Forwardable
    def_delegator :@pager, :first, :first
    def_delegator :@pager, :last, :last
    def_delegator :items, :each
    def_delegator :items, :each_with_index    
        
    attr_reader :number, :pager
    
    def initialize(pager, number, select) #:nodoc:
      @pager, @number = pager, number
      @offset = (number - 1) * pager.per_page
      @select = select
    end
    
    # Retrieve the items for this page
    # * Caches
    def items
      @items ||= @select.call
    end
    
    # Checks to see if there's a page before this one
    def prev?
      @number > 1
    end
    
    # Get previous page (if possible)
    def prev
      @pager.page(@number - 1) if prev?
    end
    
    # Checks to see if there's a page after this one
    def next?
      @number < @pager.number_of_pages
    end
    
    # Get next page (if possible)
    def next
      @pager.page(@number + 1) if next?
    end
    
    # The "item number" of the first item on this page
    def first_item_number
      1 + @offset
    end
    
    # The "item number" of the last item on this page
    def last_item_number
      if next?
        @offset + @pager.per_page
      else
        @pager.count
      end
    end
    
    def ==(other) #:nodoc:
      @pager == other.pager && self.number == other.number
    end
    
  end
  
end
