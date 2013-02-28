require 'spec_helper'

describe Content::PostsController do

  describe "GET 'index'" do
    it "returns http success" do
      user = User.create!(email: "test@email.com", branch: "GB")
      resource = Content::Post.create!(title: "title", body: "hello", user_id: user.id)
      sleep 1
      get :index
      assigns(:resources).should eq([resource])
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      user = User.create!(email: "test@email.com", branch: "GB")
      resource = Content::Post.create!(title: "title", body: "body", user_id: user.id)
      get :show, :id => resource.slug
      assigns(:resource).should eq(resource)
      response.should be_success
    end
  end

end
