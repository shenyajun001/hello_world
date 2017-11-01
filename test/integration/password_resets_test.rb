require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'

    post password_resets_path,params:{password_reset:{email:''}}
    assert_not flash.empty?
    assert_template 'password_resets/new'

    post password_resets_path,params:{password_reset:{email:@user.email}}
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1,ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url

    user = assigns(:user)

    get edit_password_reset_url(user.reset_token,email:'')
    assert_redirected_to root_url

    get edit_password_reset_url("wrong token",email:user.email)
    assert_redirected_to root_url

    user.toggle!(:activated)
    get edit_password_reset_url(user.reset_token,email:user.email)	
    assert_redirected_to root_url
    user.toggle!(:activated)

    get edit_password_reset_url(user.reset_token,email:user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]",user.email

    patch password_reset_path(user.reset_token),
	  params:{email:user.email,
		  user:{password:"foobaz",
			password_confirmation:"dsfdsfs"}}
    assert_select 'div#error_explanation'

    patch password_reset_path(user.reset_token),
	  params:{email:user.email,
		  user:{password:"",
			password_confirmation:""}}
    assert_select 'div#error_explanation'

    patch password_reset_path(user.reset_token),
	  params:{email:user.email,
		  user:{password:"foobaz",
			password_confirmation:"foobaz"}}
    assert is_logged_in?
    assert_nil user.reload.reset_digest
    assert_not flash.empty?
    assert_redirected_to user
  end

  test "expired token" do
    @user.create_reset_digest
    @user.update_attribute(:reset_send_at,3.hours.ago)
    get edit_password_reset_url(@user.reset_token,email:@user.email)
    assert_response :redirect
    follow_redirect!
    assert_match /expired/i,response.body
  end
end
