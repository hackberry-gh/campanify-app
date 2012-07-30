require 'spec_helper'

describe Content::PagesController do

  describe "GET 'show'" do
    it "returns http success" do
      page = Content::Page.create!(title: "title", body: "body")
      get :show, :id => "title"
      assigns(:page).should eq(page)
      response.should be_success
    end
  end

end
