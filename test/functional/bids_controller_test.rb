require 'test_helper'

class BidsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:bids)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_bid
    assert_difference('Bid.count') do
      post :create, :bid => { }
    end

    assert_redirected_to bid_path(assigns(:bid))
  end

  def test_should_show_bid
    get :show, :id => bids(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => bids(:one).id
    assert_response :success
  end

  def test_should_update_bid
    put :update, :id => bids(:one).id, :bid => { }
    assert_redirected_to bid_path(assigns(:bid))
  end

  def test_should_destroy_bid
    assert_difference('Bid.count', -1) do
      delete :destroy, :id => bids(:one).id
    end

    assert_redirected_to bids_path
  end
end
