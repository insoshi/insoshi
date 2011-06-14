require 'test_helper'

class MemberPreferencesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:member_preferences)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create member_preference" do
    assert_difference('MemberPreference.count') do
      post :create, :member_preference => { }
    end

    assert_redirected_to member_preference_path(assigns(:member_preference))
  end

  test "should show member_preference" do
    get :show, :id => member_preferences(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => member_preferences(:one).to_param
    assert_response :success
  end

  test "should update member_preference" do
    put :update, :id => member_preferences(:one).to_param, :member_preference => { }
    assert_redirected_to member_preference_path(assigns(:member_preference))
  end

  test "should destroy member_preference" do
    assert_difference('MemberPreference.count', -1) do
      delete :destroy, :id => member_preferences(:one).to_param
    end

    assert_redirected_to member_preferences_path
  end
end
