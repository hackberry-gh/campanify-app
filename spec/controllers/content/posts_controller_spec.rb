require 'spec_helper'

describe Content::PostsController do

  describe "GET 'index'" do
    it "returns http success" do
      resource = Content::Post.create!(name: "title", created_at: Time.now)
      get :show, :id => resource.id
      assigns(:resources).should eq([resource])
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      resource = Content::Post.create!(title: "title", body: "body")
      get :show, :id => resource.slug
      assigns(:resource).should eq(resource)
      response.should be_success
    end
  end

end
