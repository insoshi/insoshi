require File.join(File.dirname(__FILE__), 'rails', 'test_preamble')

class MarkabyController < ActionController::Base

  helper :test
  
  @@locals = { :monkeys => Monkey.find(:all) }

  def rescue_action(e) raise e end;

  def index
    @monkeys = Monkey.find(:all)
  end
  
  def create
    flash[:message] = 'Hello World'
  end

  def broken
  end
  
  def partial_rendering
    render :partial => 'monkeys', :locals => @@locals
  end
  
  def partial_rendering_with_stringy_keys_in_local_assigns
    render :partial => 'monkeys', :locals => { 'monkeys' => Monkey.find(:all) }
  end

  def inline_helper_rendering
    render_markaby(:locals => @@locals) { ul { monkeys.each { |m| li m.name } } }
  end
  
  def basic_inline_rendering
    render :inline => mab { ul { Monkey.find(:all).each { |m| li m.name } } }
  end

end

class MarkabyOnRailsTest < Test::Unit::TestCase
  def setup
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @controller = MarkabyController.new
    @controller.template_root = File.join(File.dirname(__FILE__), 'rails')
    @expected_monkey_names = '<ul><li>Frank</li><li>Benny</li><li>Paul</li></ul>'
  end
  
  def test_index
    process :index
    assert_response :success
    assert_template 'markaby/index'
    assert_equal @expected_monkey_names, @response.body
  end
  
  def test_partial_rendering
    Markaby::Builder.set :indent, 2
    process :partial_rendering
    expected_html = File.read(File.join(File.dirname(__FILE__), 'rails', 'monkeys.html'))
    assert_response :success
    assert_template 'markaby/_monkeys'
    assert_equal expected_html, @response.body
    
    # From actionpack/lib/action_view/base.rb:
    #   String keys are deprecated and will be removed shortly.
    #
    assert_raises ActionView::TemplateError do
      process :partial_rendering_with_stringy_keys_in_local_assigns
    end
  end

  def test_inline_helper_rendering
    process :inline_helper_rendering
    assert_response :success
    assert_equal @expected_monkey_names, @response.body
  end  

  def test_basic_inline_rendering
    process :basic_inline_rendering
    assert_response :success
    assert_equal @expected_monkey_names, @response.body
  end  

  def test_flash_and_form_tag
    process :create
    assert_response :success
    assert_select 'form div input[type=submit]', 1
    assert_select 'p', 'Hello World'
  end
  
  def test_template_error_has_correct_line_number
    begin
      process :broken
    rescue ActionView::TemplateError => error
      assert_equal 5, error.line_number.to_i
    end
  end

end
