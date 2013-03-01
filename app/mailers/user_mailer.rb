class UserMailer < ActionMailer::Base
  default from: Settings.mailer["sender"]

  def email(email, user)
    @user = user
    @email = email
    mail to: user.email_address, 
    subject: I18n.with_locale(user.language){ 
      I18n.t("user_mailer.#{email}.subject") 
    }
  end
end
