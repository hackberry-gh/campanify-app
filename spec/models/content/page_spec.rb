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
  
  it "has many widgets and widgets are shareable across pages" do
    page = Content::Page.create!(title: "Test Page", body: "Test Page Body")
    widget1 = page.widgets.create(title: "widget 1", body: "widget 1")
    widget2 = page.widgets.create(title: "widget 2", body: "widget 2")
    page2 = Content::Page.create!(title: "Test Page 2", body: "Test Page Body 2")
    page2.widgets << widget1
    
    page.widgets.should eq([widget1,widget2])
    page2.widgets.should eq([widget1])    
  end
end
