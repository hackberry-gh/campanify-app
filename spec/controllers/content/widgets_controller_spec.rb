require 'spec_helper'

describe Content::WidgetsController do

  describe "GET 'show'" do
    it "returns http success" do
      resource = Content::Widget.create!(title: "title", body: "body")
      get :show, :id => resource.id
      assigns(:resource).should eq(resource)
      response.should be_success
    end
  end

end
