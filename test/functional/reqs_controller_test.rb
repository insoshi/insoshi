require 'test_helper'

class ReqsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:reqs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_req
    assert_difference('Req.count') do
      post :create, :req => { }
    end

    assert_redirected_to req_path(assigns(:req))
  end

  def test_should_show_req
    get :show, :id => reqs(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => reqs(:one).id
    assert_response :success
  end

  def test_should_update_req
    put :update, :id => reqs(:one).id, :req => { }
    assert_redirected_to req_path(assigns(:req))
  end

  def test_should_destroy_req
    assert_difference('Req.count', -1) do
      delete :destroy, :id => reqs(:one).id
    end

    assert_redirected_to reqs_path
  end
end
