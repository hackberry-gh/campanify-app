require 'spec_helper'

describe Settings do
  
  it "ensure that you never get duplicate records" do
    -> { Settings.new }.should raise_error
  end

	it "contains default data" do
		Settings.instance.data.should eq(Settings.defaults)
	end

	it "store key value pairs with dot notation" do
		Settings.my_string = "String Test"
		Settings.my_string.should eq("String Test")

		Settings.my_integer = 0
		Settings.my_integer.should eq(0)

		Settings.my_float = 1.0
		Settings.my_float.should eq(1.0)    

		Settings.my_symbol = :symbol
		Settings.my_symbol.should eq(:symbol)    

		Settings.my_array = ["elm1", 0, 2]
		Settings.my_array.should eq(["elm1", 0, 2])    

		Settings.my_hash = {:key => "value"}
		Settings.my_hash.should eq({:key => "value"})    

		Settings.my_array_of_hash = [{:key => "value"},{:key2 => "value2"}]
		Settings.my_array_of_hash.should eq([{:key => "value"},{:key2 => "value2"}])    

		Settings.mixed = [0, "string", {:key => "value", :key_array => ["string", 1, 5.0]}]
		Settings.mixed.should eq([0, "string", {:key => "value", :key_array => ["string", 1, 5.0]}])    
	end

	it "should reset to default" do
		Settings.reset!
		Settings.instance.data.should eq(Settings.defaults)
	end

	it "dumps everything" do
		Settings.my_integer = 0
		Settings.my_string = "string"
		data = Settings.defaults.clone.merge({"my_integer" => 0, "my_string" => "string"})
		Settings.dump.should eq(data)
	end

	it "fetches user settings by branch fallback from defaults" do
		Settings.user_setting("fields").should eq(Settings.user["fields"])
		Settings.user_setting("fields", "GB").should eq(Settings.branches["GB"]["user"]["fields"])
		Settings.user_setting("fields", "NON_EXISTS_BRANCH").should eq(Settings.user["fields"])    
	end
end
