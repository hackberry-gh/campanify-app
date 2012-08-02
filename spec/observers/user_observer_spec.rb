require 'spec_helper'

describe UserObserver do
  it "runs hooks after user created,updated or deleted" do
    
    Settings.user["hooks"]["after_create"] = {
      "user" => "generate_reset_password_token",
      "mail" => "after_signup_email",
      "http_post" => "http://localhost:5000/users/hooks/http_post"
    }
    
    user = User.create!(email: "test@test.com",
    first_name: "test", last_name: "test")
    
    user.reset_password_token.should_not eql(nil)

  end
end
