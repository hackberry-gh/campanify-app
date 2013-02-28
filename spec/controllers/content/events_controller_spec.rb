require 'spec_helper'

describe Content::EventsController do

  describe "GET 'index'" do
    it "returns http success" do
      resource = Content::Event.create!(name: "title", start_time: Time.now, :privacy => "OPEN")
      get :index
      assigns(:resources).should eq([resource])
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      resource = Content::Event.create!(name: "title", start_time: Time.now, :privacy => "OPEN")
      get :show, :id => resource.slug
      assigns(:resource).should eq(resource)
      response.should be_success
    end
  end

end
