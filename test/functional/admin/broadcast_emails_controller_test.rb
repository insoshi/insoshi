require 'test_helper'

class Admin::BroadcastEmailsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_broadcast_emails)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_broadcast_email
    assert_difference('Admin::BroadcastEmail.count') do
      post :create, :broadcast_email => { }
    end

    assert_redirected_to broadcast_email_path(assigns(:broadcast_email))
  end

  def test_should_show_broadcast_email
    get :show, :id => admin_broadcast_emails(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => admin_broadcast_emails(:one).id
    assert_response :success
  end

  def test_should_update_broadcast_email
    put :update, :id => admin_broadcast_emails(:one).id, :broadcast_email => { }
    assert_redirected_to broadcast_email_path(assigns(:broadcast_email))
  end

  def test_should_destroy_broadcast_email
    assert_difference('Admin::BroadcastEmail.count', -1) do
      delete :destroy, :id => admin_broadcast_emails(:one).id
    end

    assert_redirected_to admin_broadcast_emails_path
  end
end
