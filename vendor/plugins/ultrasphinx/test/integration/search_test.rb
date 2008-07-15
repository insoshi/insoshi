
require "#{File.dirname(__FILE__)}/../test_helper"

class SearchTest < Test::Unit::TestCase

  S = Ultrasphinx::Search
  E = Ultrasphinx::UsageError
  STRFTIME = "%b %d %Y %H:%M:%S" # Chronic can't parse the default date .to_s

  def test_simple_query
    assert_nothing_raised do
      @s = S.new(:query => 'seller').run
    end
    assert_equal 20, @s.size
  end  
  
  def test_with_subtotals_option
    S.client_options['with_subtotals'] = true
    
    # No delta index; accurate subtotals sum
    @s = S.new(:indexes => Ultrasphinx::MAIN_INDEX).run
    assert_equal @s.total_entries, @s.subtotals.values._sum
    
    # With delta; subtotals sum not less than total sum
    @s = S.new.run
    assert @s.subtotals.values._sum >= @s.total_entries 
    
    # With delta and filter; request class gets accurate count regardless
    @s = S.new(:class_names => 'Seller').run
    assert_equal @s.total_entries, @s.subtotals['Seller']    
    assert @s.subtotals.values._sum >= @s.total_entries 
    
    S.client_options['with_subtotals'] = false
  end
  
  def test_ignore_missing_records_option
    S.client_options['distance'] = false # must disable geodistance or line 57 will bomb
    @s = S.new(:per_page => 1).run
    @record = @s.first
    assert_equal 1, @s.size
    
    @record.destroy

    assert_raises(ActiveRecord::RecordNotFound) do
      @s = S.new(:per_page => 1).run
    end    
    
    S.client_options['ignore_missing_records'] = true
    assert_nothing_raised do
      @s = S.new(:per_page => 1).run
    end 
    assert_equal 0, @s.size
    assert_equal 1, @s.per_page
    S.client_options['ignore_missing_records'] = false
  
    # Re-insert the record... ugh
    @new_record = @record.class.new(@record.attributes)
    @new_record.id = @record.id
    @new_record.save!
  end
  
  def test_query_retries_and_fails
    system("cd #{RAILS_ROOT}; rake ultrasphinx:daemon:stop &> /dev/null")
    assert_raises(Ultrasphinx::DaemonError) do
      S.new.run
    end
    system("cd #{RAILS_ROOT}; rake ultrasphinx:daemon:start &> /dev/null")
  end
  
  def test_accessors
    @per_page = 5
    @page = 3
    @s = S.new(:query => 'seller', :per_page => @per_page, :page => @page).run
    assert_equal @per_page, @s.per_page
    assert_equal @page, @s.page
    assert_equal @page - 1, @s.previous_page
    assert_equal @page + 1, @s.next_page
    assert_equal @per_page * (@page - 1), @s.offset
    assert @s.total_pages >= @s.total_entries / @per_page.to_f
   end
  
  def test_empty_query
    assert_nothing_raised do
      @s = S.new.run
    end 
  end
  
  def test_total_entries
    @total = Ultrasphinx::MODEL_CONFIGURATION.keys.inject(0) do |acc, class_name| 
      acc + class_name.constantize.count
    end - User.count(:conditions => {:deleted => true })
    
    assert_equal(
      @total,
      @s = S.new.run.total_entries
    )  
  end
  
  def test_individual_totals_with_pagination
    Ultrasphinx::MODEL_CONFIGURATION.keys.each do |class_name| 
      if class_name == "User"
        assert_equal User.count(:conditions => {:deleted => false }), 
          S.new(:class_names => class_name, :page => 2).total_entries
      else
        assert_equal class_name.constantize.count, 
          S.new(:class_names => class_name, :page => 2).total_entries
      end
    end
  end

  def test_individual_totals_without_pagination
    Ultrasphinx::MODEL_CONFIGURATION.keys.each do |class_name| 
      begin
        if class_name == "User"
          assert_equal User.count(:conditions => {:deleted => false }), 
            S.new(:class_names => class_name).total_entries
        else
          assert_equal class_name.constantize.count, 
            S.new(:class_names => class_name).total_entries
        end
      rescue Object
        raise class_name
      end
    end
  end
  
  def test_sort_by_date
    assert_equal(
      Seller.find(:all, :limit => 5, :order => 'created_at DESC').map(&:created_at),
      S.new(:class_names => 'Seller', :sort_by => 'created_at', :sort_mode => 'descending', :per_page => 5).run.map(&:created_at)
    )
  end

  def test_sort_by_float
    assert_equal(
      Seller.find(:all, :limit => 5, :order => 'capitalization ASC').map(&:capitalization),
      S.new(:class_names => 'Seller', :sort_by => 'capitalization', :sort_mode => 'ascending', :per_page => 5).run.map(&:capitalization)
    )
  end
  
  def test_sort_by_string
    assert_equal(
      Seller.find(:all, :limit => 5, :order => 'mission_statement ASC').map(&:mission_statement),
      S.new(:class_names => 'Seller', :sort_by => 'mission_statement', :sort_mode => 'ascending', :per_page => 5).run.map(&:mission_statement)
    )
    assert S.new(:sort_by => 'mission_statement', :sort_mode => 'ascending').run.size > 0
  end
 
  def test_sort_by_string_using_query
    assert_equal(
      Seller.find(10,11, :order => 'mission_statement ASC').map(&:mission_statement),
      S.new(:class_names => 'Seller', :query => 'seller10 or seller11', :sort_by => 'mission_statement', :sort_mode => 'ascending', :per_page => 2).run.map(&:mission_statement)
    )
  end 
 
  def test_filter
    assert_equal(
      Seller.count(:conditions => 'user_id = 17'),
      S.new(:class_names => 'Seller', :filters => {'user_id' => 17}).run.size
    )
  end
  
  def test_nil_filter
    # XXX
  end
  
  def test_float_range_filter
    @count = Seller.count(:conditions => 'capitalization <= 29.5 AND capitalization >= 10')
    assert_equal(@count,
      S.new(:class_names => 'Seller', :filters => {'capitalization' => 10..29.5}).run.size)
    assert_equal(@count,
      S.new(:class_names => 'Seller', :filters => {'capitalization' => 29.5..10}).run.size)
  end

  def test_date_range_filter
    @first, @last = Seller.find(5).created_at, Seller.find(10).created_at
    @items = Seller.find(:all, :conditions => ['created_at >= ? AND created_at <= ?', @last, @first]).sort_by(&:id)
    @count = @items.size
    
    @search = S.new(:class_names => 'Seller', :filters => {'created_at' => @first..@last}).run.sort_by(&:id)
    assert_equal(@count, @search.size)
    assert_equal(@items.first.created_at, @search.first.created_at)
    assert_equal(@items.last.created_at, @search.last.created_at)
    
    assert_equal(@count,
      S.new(:class_names => 'Seller', :filters => {'created_at' => @last..@first}).run.size)
    assert_equal(@count,
      S.new(:class_names => 'Seller', :filters => {'created_at' => @last.strftime(STRFTIME)..@first.strftime(STRFTIME)}).run.size)

    assert_raises(Ultrasphinx::UsageError) do
      S.new(:class_names => 'Seller', :filters => {'created_at' => "bogus".."sugob"}).run.size
    end
  end
    
  def test_text_filter
    assert_equal(
      Seller.count(:conditions => "company_name = 'seller17'"),
      S.new(:class_names => 'Seller', :filters => {'company_name' => 'seller17'}).run.size
    )  
  end
  
  def test_invalid_filter
    assert_raises(Ultrasphinx::UsageError) do
      S.new(:class_names => 'Seller', :filters => {'bogus' => 17}).run
    end
  end
  
  def test_conditions
    @deleted_count = User.count(:conditions => {:deleted => true })
    assert_equal 1, @deleted_count
    assert_equal User.count - @deleted_count, S.new(:class_names => 'User').run.total_entries 
  end
  
  #  def test_mismatched_facet_configuration
  #    # XXX Should be caught at configuration time. For now it's your own fault 
  #    # if you do it and get confused.
  #    assert_raises(Ultrasphinx::ConfigurationError) do 
  #      Ultrasphinx::Search.new(:facets => 'company_name').run
  #    end
  #  end
  
  def test_bogus_facet_name
    assert_raises(Ultrasphinx::UsageError) do
      Ultrasphinx::Search.new(:facets => 'bogus').run
    end
  end  
  
  def test_unconfigured_sortable_name
    assert_raises(Ultrasphinx::UsageError) do
      S.new(:class_names => 'User', :sort_by => 'company', :sort_mode => 'ascending', :per_page => 5).run
    end
  end
  
  def test_sorting_by_field_with_relevance_order
    assert_raises(Ultrasphinx::UsageError) do
      # Defaults to :sort_mode => 'relevance'
      S.new(:class_names => 'Seller', :sort_by => 'created_at', :per_page => 5).run 
    end  
  end
  
  def test_nonexistent_sortable_name
    assert_raises(Ultrasphinx::UsageError) do
      S.new(:class_names => 'Seller', :sort_by => 'bogus', :per_page => 5).run
    end  
  end
  
  def test_text_facet
    @s = Ultrasphinx::Search.new(:facets => ['company_name']).run
    assert_equal(
      (Seller.count + 1), 
      @s.facets['company_name'].size
    )
  end

  def test_included_text_facet_without_association_sql
    # There are 40 users, but only 20 sellers. So you get 20 facets + 1 nil with 20 items
    @s = Ultrasphinx::Search.new(:class_names => 'User', :facets => ['company']).run
    assert_equal(
      (Seller.count + 1), 
      @s.facets['company'].size
    )
  end

  def test_included_text_facet_with_association_sql
    # XXX there are 40 users but only 20 sellers, but the replace function from User deletes 
    # User #6 and 16 (why? Hash collision?). There is also a nil facet that gets added for a 
    # total of 19 objects
    @s = Ultrasphinx::Search.new(:class_names => 'User', :facets => ['company_two']).run
    assert_equal(
      (Seller.count - 1), 
      @s.facets['company_two'].size
    )
  end
  
  def test_numeric_facet
    @user_id_count = Seller.find(:all).map(&:user_id).uniq.size

    @s = Ultrasphinx::Search.new(:class_names => 'Seller', :facets => 'user_id').run
    assert_equal @user_id_count, @s.facets['user_id'].size

    @s = Ultrasphinx::Search.new(:facets => 'user_id').run
    assert_equal @user_id_count + 1, @s.facets['user_id'].size
    assert @s.facets['user_id'][0] > 1
  end
  
  def test_multi_facet
    @facets = ['user_id', 'capitalization', 'company_name']
    @s = Ultrasphinx::Search.new(:facets => @facets).run
    @facets.each do |facet|
      assert @s.facets[facet]
      assert @s.facets[facet].any?
    end
  end
  
  def test_float_facet
    @s = Ultrasphinx::Search.new(:class_names => 'Seller', :facets => 'capitalization').run
    @s.facets['capitalization'].keys.each do |key|
      # XXX http://www.sphinxsearch.com/forum/view.html?id=963
      # assert key.is_a?(Float)
    end
  end
  
  def test_table_aliasing_and_association_sql
    assert_equal 2, Ultrasphinx::Search.new(:class_names => 'User', :query => 'company_two:replacement').run.size
  end
    
  def test_weights
    @unweighted = Ultrasphinx::Search.new(:query => 'seller16', :per_page => 1).run.first
    @weighted = Ultrasphinx::Search.new(:query => 'seller16', :weights => {'company' => 2}, :per_page => 1).run.first
    assert_not_equal @unweighted, @weighted
  end
  
  def test_excerpts
    @s = Ultrasphinx::Search.new(:class_names => 'Seller', :query => 'seller10')
    @excerpted_item = @s.excerpt.first
    @item = @s.run.first
    assert_not_equal @item.name, @excerpted_item.name
    assert_match /strong/, @excerpted_item.name
  end
  
  def test_distance_ascending
    # (21.289453, -157.842783) is Ala Moana Shopping Center, 1450 Ala Moana Blvd, Honolulu HI 96814
    @s = Ultrasphinx::Search.new(:class_names => 'Geo::Address', 
          :query => 'Honolulu',
          :per_page => 40,
          :sort_mode => 'extended',
          :sort_by => 'distance',
          :location => {
            :lat => 21.289453,
            :long => -157.842783
          })
    @s.run
    # This should return all items in the database, sorted in increasing distance
    assert_equal 40, @s.size
    assert_match /Waikiki Aquarium/, @s.first.name
    assert_match /Waikiki Aquarium/, @s[1].name
    assert_in_delta 3439, @s.first.distance, 10
  end
  
  def test_distance_filter
    # (21.289453, -157.842783) is Ala Moana Shopping Center, 1450 Ala Moana Blvd, Honolulu HI 96814
    @s = Ultrasphinx::Search.new(:class_names => 'Geo::Address', 
          :query => 'Honolulu',
          :per_page => 40,
          :sort_mode => 'extended',
          :sort_by => 'distance',
          :filters => {'distance' => 0..5000},
          :location => {
            :lat => 21.289453,
            :long => -157.842783
          })
    @s.run

    @s.each do |obj|
      # This should return only those items within 5000 meters of Ala Moana, which 
      # is only Waikiki Aquarium and Diamond Head.
      assert_match /Waikiki Aquarium|Diamond Head/, obj.name
    end
        
    assert_in_delta 3439, @s.first.distance, 10 # Closest item should be Waikiki at 3439 meters
  end
  
  def test_distance_decending
    # (21.289453, -157.842783) is Ala Moana Shopping Center, 1450 Ala Moana Blvd, Honolulu HI 96814
    @s = Ultrasphinx::Search.new(:class_names => 'Geo::Address', 
          :query => 'Honolulu',
          :per_page => 40,
          :sort_mode => 'extended',
          :sort_by => 'distance desc',
          :location => {
            :lat => 21.289453,
            :long => -157.842783
          })
    @s.run
    
    # Ids should come back in reverse order because the fixtures have the farther locations later in the file
    assert_equal 40, @s.size
    assert_match /Kailua Beach Park/, @s.first.name 
    assert_in_delta 16940, @s.first.distance, 40
  end
end