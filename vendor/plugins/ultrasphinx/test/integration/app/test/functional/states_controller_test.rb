require File.dirname(__FILE__) + '/../test_helper'
require 'states_controller'

# Re-raise errors caught by the controller.
class StatesController; def rescue_action(e) raise e end; end

class StatesControllerTest < Test::Unit::TestCase
  fixtures :states

  def setup
    @controller = StatesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:states)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_state
    assert_difference('Geo::State.count') do
      post :create, :state => { :name => 'test', :abbreviation => 'te' }
    end

    assert_redirected_to state_path(assigns(:state))
  end

  def test_should_show_state
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_state
    put :update, :id => 1, :state => { }
    assert_redirected_to state_path(assigns(:state))
  end

  def test_should_destroy_state
    new_state = Geo::State.new(:name => 'test', :abbreviation => 'te')
    
    assert_difference('Geo::State.count', +1) do
      new_state.save
    end

    assert_difference('Geo::State.count', -1) do
      delete :destroy, :id => new_state.id
    end
    
    assert_redirected_to states_path
  end
end
