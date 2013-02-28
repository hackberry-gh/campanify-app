require 'spec_helper'

describe Content::Page do
  it "has slug and publishable" do
    page = Content::Page.create!(title: "Test Page", body: "Test Page Body")
    page.published?.should eq(true)
    page.slug.should eq('test-page')
    page.unpublish!
    page.reload
    sleep(1)
    page.published?.should eq(false)    
    page.publish!
    page.reload    
    sleep(1)
    page.published?.should eq(true)    
    Content::Page.published.length.should eq(1)
  end
  
  
end
