require 'spec_helper'

describe Appearance::Asset do
  it "only accepts css and javascript files and needs body" do
    -> { Appearance::Asset.create!(filename: "badfilename.png", content_type: "image/png") }.should raise_error(ActiveRecord::RecordInvalid)
  end
  
  it "compress and uploads asset content with its name and unlink files before destroy" do
    asset1 = Appearance::Asset.create!(filename: "test.css", content_type: Appearance::Asset::VALID_TYPES[:css], body: "body{background_color: #fff;}")    
    asset2 = Appearance::Asset.create!(filename: "test.js", content_type: Appearance::Asset::VALID_TYPES[:js], body: "(function(){ window.alert('hello world'); })();")
  
    asset1.value.should eq(asset1.compressed_body)    
    asset2.value.should eq(asset2.compressed_body)    
    
    asset1.destroy
    asset2.destroy
    
    asset1.exists?.should eq(false)
    asset2.exists?.should eq(false)    
  end
end
