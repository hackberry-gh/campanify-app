require 'spec_helper'

describe Content::EventsController do

  describe "GET 'index'" do
    it "returns http success" do
      resource = Content::Event.create!(name: "title", created_at: Time.now)
      get :show, :id => resource.id
      assigns(:resources).should eq([resource])
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      resource = Content::Event.create!(name: "title", created_at: Time.now)
      get :show, :id => resource.id
      assigns(:resource).should eq(resource)
      response.should be_success
    end
  end

end
