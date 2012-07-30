class UserMailer < ActionMailer::Base
  default from: Settings.mailer["sender"]

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.post_signup_email.subject
  #
  def post_signup_email(user)
    @user = user
    mail to: user.email_address, subject: I18n.with_locale(user.language){ 
      I18n.t('user_mailer.post_signup_email.subject') 
    }
  end
end
