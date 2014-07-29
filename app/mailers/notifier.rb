class Notifier < ActionMailer::Base
  default from: "mail@ffaerber.com"

  def welcome(user)
    mail(to: user.email, subject: "subject")
  end

end
