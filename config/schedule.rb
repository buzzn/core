env :PATH, '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/opt/aws/bin'

set :output, 'log/cron.log'

every 1.day, :at => '4:00 am' do
  runner "Group::Base.calculate_scores"
end
