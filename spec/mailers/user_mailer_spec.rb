require "spec_helper"

describe UserMailer do
  
  describe "after_signup_email" do
        
    user = User.create!(email: "test@test2.com", branch: "GB")
        
    let(:mail) { UserMailer.after_signup_email(user) }

    it "renders the headers" do
      mail.subject.should eq(I18n.t('user_mailer.after_signup_email.subject'))
      mail.to.should eq([user.email_address])
      mail.from.should eq([Settings.mailer["sender"]])
    end

    it "renders the body" do
      # body = I18n.t("user_mailer.after_signup_email.body", user.as_json_with_tokens)      
      # mail.body.encoded.should match(body)
      mail.body.encoded.should include(user.id.to_s)      
    end
    
    user.destroy
    
  end

end
