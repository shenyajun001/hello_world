require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
def setup
  ActionMailer::Base.deliveries.clear
end

test "invalid signup information" do
  get signup_path
  assert_no_difference 'User.count' do
    post signup_path, params:{user:{name:"",
			     email:"dfsdff",
			     password:"foo",
			     password_confirmation:"bar"}}
  end
  assert_template 'users/new'
  assert_select 'div#error_explanation'
  assert_select 'div.alert'
  assert_select 'div.alert-danger'
end

test "valid signup infromation" do
  get signup_path
  assert_difference 'User.count',1 do
    post users_path,params:{user:{name:'peiyanli',email:'peiyanli@xiaozh.com',
				  password:'hahaha',password_confirmation:'hahaha'}}
  end
  assert_equal 1,ActionMailer::Base.deliveries.size
  user = assigns(:user)
  assert_not user.activated?
  log_in_as(user)
  assert_not is_logged_in?
  get edit_account_activation_path("invalid token",email:user.email)
  assert_not is_logged_in?
  get edit_account_activation_path(user.activation_token,email:'wrong')
  assert_not is_logged_in?
  get edit_account_activation_path(user.activation_token,email:user.email)
  assert user.reload.activated?
  follow_redirect!
  assert_template 'users/show'
  assert is_logged_in?
end
end
