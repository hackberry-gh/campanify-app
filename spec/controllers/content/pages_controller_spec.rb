require 'spec_helper'

describe Content::PagesController do

  describe "GET 'show'" do
    it "returns http success" do
      resource = Content::Page.create!(title: "title", body: "body")
      get :show, :id => resource.slug
      assigns(:resource).should eq(resource)
      response.should be_success
    end
  end

end
