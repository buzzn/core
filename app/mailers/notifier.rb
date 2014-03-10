class Notifier < ActionMailer::Base
  default from: "mail@buzzn.net"

  def welcome(user)
    mail(to: user.email, subject: "subject")
  end

end
