require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user),params:{user:{name:"",
                                         email:"foo@invalid",
                                         password:"foo",
                                         password_confirmation:"bar"}}
    assert_template 'users/edit'
    assert_select "div.alert","The form contains 4 errors"
  end

  test "successful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user),params:{user:{name:name,
                                         email:email,
                                         password:"",
                                         password_confirmation:""}}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,@user.name
    assert_equal email,@user.email
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)  
    log_in_as(@user)
    get edit_user_path(@user)
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user),params:{user:{name:name,
                                         email:email,
                                         password:"",
                                         password_confirmation:""}}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,@user.name
    assert_equal email,@user.email
  end

  test "第二次登陆不会跳转受保护页面" do
    get edit_user_path(@user)
    follow_redirect!
    post login_path,params:{session:{email:@user.email,
                                     password:'password'}}
    follow_redirect!
    assert_template 'users/edit'
    delete logout_path
    get login_path
    post login_path,params:{session:{email:@user.email,
                                     password:'password'}}
    follow_redirect!
    assert_template 'users/show'
  end 

end
