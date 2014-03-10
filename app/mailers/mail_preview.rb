# app/mailers/mail_preview.rb or lib/mail_preview.rb
class MailPreview < MailView

  def welcome
    user = User.last
    mail = Notifier.welcome(user)
  end

  def forgot_password
    user = User.last
    mail = Notifier.forgot_password(user)
  end

end