require 'spec_helper'

describe Administrator do
  it "sends reset password instructions after create" do
    admin = Administrator.create!(email: "test@test.com")
    admin.reset_password_token.should_not eq(nil)
  end
end
