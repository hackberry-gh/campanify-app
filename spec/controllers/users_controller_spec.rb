require 'spec_helper'

describe UsersController do
  login_user

  describe "GET 'index'" do
    it "returns http success" do
      # user = User.create!(email: "test@test.com", first_name: "first_name", last_name: "last_name")      
      get 'index'
      assigns(:users).should eq([@user])
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      # user = User.create!(email: "test@test.com", first_name: "first_name", last_name: "last_name")
      get :show, :id => @user.id
      assigns(:user).should eq(@user)
      response.should be_success
    end
  end

  describe "PUT 'visits'" do
    it "returns http success" do
      user = User.create!(email: "test@test.com", first_name: "first_name", last_name: "last_name")      
      xhr :put, :visits, :id => user.id
      assigns(:user).should eq(user)
      user.reload
      user.total_visits(false).should eq(1)
      response.should be_success
    end
  end

end
