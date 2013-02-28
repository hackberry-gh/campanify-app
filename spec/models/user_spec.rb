require 'spec_helper'

describe User do
  
  it "requires password based on settings" do
    User.new(email: "test@test.com").password_required?.should eql(false)
  end
  
  it "validates fields dynamicaly based on settings" do
    -> { User.create!(email: "test@test.com") }.should raise_error(ActiveRecord::RecordInvalid)
    User.create!(email: "test@test.com", branch: "GB").new_record?.should eql(false)
  end
  
  it "tracks visits with date and ip" do
    user = User.create!(email: "test@test123456.com", branch: "GB")
    user.current_ip = "1.1.1.1"    
    user.inc_visits
    # user.reload
    # t = Time.now
    # visits_hash = {t.year => {t.month => {t.day => {t.hour => {"#{user.id}_#{user.current_ip}" => 1}}}}}
    user.total_visits.should eq(1)
    user.dec_visits
    # user.reload
    user.daily_visits.should eq(0)
    user.set_visits(5)
    # user.reload
    user.hourly_visits(false).should eq(5)
  end
  
end
