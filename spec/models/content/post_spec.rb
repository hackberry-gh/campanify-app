require 'spec_helper'

describe Content::Post do
  it "has slug and publishable" do
    user = User.create!(email: "test@test.com", branch: "GB")
    post = Content::Post.create!(title: "Test Post", body: "Test Post Body", user_id: user.id)
    post.published?.should eq(true)
    post.slug.should eq('test-post')
    post.unpublish!
    sleep(1)
    post.published?.should eq(false)    
    post.publish!
    sleep(1)
    post.published?.should eq(true)    
    Content::Post.published.length.should eq(1)
  end
end
