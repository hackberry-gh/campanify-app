require 'spec_helper'

describe Content::Widget do
  it "orders itselfs" do
    w1 = Content::Widget.create!(title: "test", body: "test")
    w2 = Content::Widget.create!(title: "test", body: "test", position: 2)
    
    Content::Widget.ordered.first.should eq(w1)
    Content::Widget.ordered.last.should eq(w2)    
    
  end
end
