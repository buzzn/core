class Notifier < ActionMailer::Base
  default from: "system@buzzn.net"

  def welcome(user)
    mail(to: user.email, subject: "subject")
  end

  def send_email_notification_meter_offline(user, metering_point)
    @user = user
    @metering_point = metering_point
    mail(to: user.email, subject: t('your_metering_point_is_offline_now', metering_point_name: metering_point.name))
  end

end
