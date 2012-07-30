require "spec_helper"

describe UserMailer do
  
  describe "post_signup_email" do
        
    user = User.create!(email: "test@test2.com",
    first_name: "test", last_name: "test")
        
    let(:mail) { UserMailer.post_signup_email(user) }

    it "renders the headers" do
      puts user
      subject = I18n.t('user_mailer.post_signup_email.subject')      
      mail.subject.should eq(subject)
      mail.to.should eq([user.email])
      mail.from.should eq([Settings.mailer["sender"]])
    end

    it "renders the body" do
      # body = I18n.t("user_mailer.post_signup_email.body", user.as_json_with_tokens)      
      # mail.body.encoded.should match(body)
      mail.body.encoded.should include(user.first_name)      
    end
    
    user.destroy
    
  end

end
