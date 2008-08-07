
require "#{File.dirname(__FILE__)}/../test_helper"

class DeltaTest < Test::Unit::TestCase

  S = Ultrasphinx::Search
  E = Ultrasphinx::UsageError
  STRFTIME = "%b %d %Y %H:%M:%S" # Chronic can't parse the default date .to_s
  
  def test_delta_update
  
    # XXX Not really necessary?
    Dir.chdir "#{HERE}/integration/app" do    
      Echoe.silence do
        system("rake db:fixtures:load")
        system("rake ultrasphinx:index")
      end
    end

    @count = S.new.total_entries

    @new = User.new
    @new.save!
    User.find(2).update_attribute(:created_at, Time.now)
    
    Dir.chdir "#{HERE}/integration/app" do    
      Echoe.silence { system("rake ultrasphinx:index:delta") }
    end
    
    assert_equal @count + 1, S.new.total_entries
    @new.destroy

    Dir.chdir "#{HERE}/integration/app" do    
      Echoe.silence { system("rake ultrasphinx:index:delta") }
    end

    assert_equal @count, S.new.total_entries
  end
  
  def test_merge
    Dir.chdir "#{HERE}/integration/app" do    
      Echoe.silence do
        system("rake ultrasphinx:daemon:start")
      end

      output = `rake ultrasphinx:index:merge 2>&1`
      assert_match /merged 0.1 Kwords/, output
      assert_match /Index rotated ok/, output
    end
  end  
  
end
