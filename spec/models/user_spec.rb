require 'spec_helper'

describe User do
  
  it "requires password based on settings" do
    User.new(email: "test@test.com").password_required?.should eql(false)
  end
  
  it "validates fields dynamicaly based on settings" do
    Settings.branches["GB"]["user"]["validates"] = {"first_name" => {"presence" => true}}
    Settings.instance.save!
    -> { User.create!(email: "test@test.com", branch: "GB") }.should raise_error(ActiveRecord::RecordInvalid)
    User.create!(email: "test@test.com", first_name: "hello", branch: "GB").new_record?.should eql(false)
    User.create!(email: "test@test.com").new_record?.should eql(false)
  end
  
  it "tracks visits with date and ip" do
    Level.create!(slug: "level1", sequence: 1, meta:{"requirements" => {"total_amount_of_points" => 2}})
    Level.create!(slug: "level2", sequence: 2, meta:{"requirements" => {"total_amount_of_points" => 4, "recruits" => 1}})
    Level.create!(slug: "level3", sequence: 3, meta:{"requirements" => {"total_amount_of_points" => 8, "recruits" => 3}})

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

  it "gains points on spesific events and jumps between levels" do
    Level.create!(slug: "level1", sequence: 1, meta:{"requirements" => {"total_amount_of_points" => 2}})
    Level.create!(slug: "level2", sequence: 2, meta:{"requirements" => {"total_amount_of_points" => 4, "recruits" => 1}})
    Level.create!(slug: "level3", sequence: 3, meta:{"requirements" => {"total_amount_of_points" => 8, "recruits" => 3}})

    user = User.create!(email: "test@test123456.com")
    # points    2,4,8
    # recruits    1,3
    (1..2).each {|i|
      user.current_ip = "1.1.1.#{i}"    
      user.inc_visits 
    }
    user.level.sequence.should eql(2)
    user.total_amount_of_points.should eql(2)
    user.total_amount_of_level_points.should eql(0)

    (1..2).each {|i|
      user.current_ip = "1.1.2.#{i}"    
      user.inc_visits 
    }
    user.inc_recruits 

    user.level.sequence.should eql(3)
    user.total_amount_of_points.should eql(9)
    user.total_amount_of_level_points.should eql(5)

    (1..4).each {|i|
      user.current_ip = "1.1.3.#{i}"    
      user.inc_visits
    }
    user.inc_recruits # 18
    user.current_ip = "1.1.4.1"    
    user.inc_recruits # 23
    user.current_ip = "1.1.4.2"    
    user.inc_recruits # 28

    user.level.sequence.should eql(3)
    user.total_amount_of_points.should eql(28)
    user.total_amount_of_level_points.should eql(24)
  end
  
end
