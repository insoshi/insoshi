require 'test_helper'

class RequestsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:requests)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_request
    assert_difference('Request.count') do
      post :create, :request => { }
    end

    assert_redirected_to request_path(assigns(:request))
  end

  def test_should_show_request
    get :show, :id => requests(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => requests(:one).id
    assert_response :success
  end

  def test_should_update_request
    put :update, :id => requests(:one).id, :request => { }
    assert_redirected_to request_path(assigns(:request))
  end

  def test_should_destroy_request
    assert_difference('Request.count', -1) do
      delete :destroy, :id => requests(:one).id
    end

    assert_redirected_to requests_path
  end
end
