require 'spec_helper'

describe CounterCache do
  it "caches model counts" do
  	User.create!(email: "user1@email.com")
  	User.create!(email: "user2@email.com")
  	User.create!(email: "user3@email.com")
  	User.create!(email: "user4@email.com")

  	CounterCache.find_by_model("User").count.should eq(4)
  	User.cached_count.should eq(User.count(:id))
  end
end
