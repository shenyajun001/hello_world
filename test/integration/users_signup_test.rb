require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
test "invalid signup information" do
  get signup_path
  assert_select 'form[action="/signup"]'
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
    post users_path,params:{user:{name:'peiyanli',email:'peiyanli@xiaozhu.com',
				  password:'hahaha',password_confirmation:'hahaha'}}
  end
  follow_redirect!
  assert_template 'users/show'
  assert_not flash.empty?
end
end
