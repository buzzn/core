env :PATH, '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/opt/aws/bin'

set :output, 'log/cron.log'


every 5.minute do
  runner "MeteringPoint.observe"
end

every 1.day, :at => '5:00 am' do
  rake "sitemap:refresh"
end

every 10.minutes do
  UpdateMeteringPointChartCache.perform_async(Time.current, 'day_to_minutes')
end

# every 1.minute do
#   runner "Meter.pull_readings"
# end

# every 3.minute do
#   runner "Group.update_cache"
#   #runner "MeteringPoint.update_cache"
# end

# every 30.minutes do
#   runner "Meter.reactivate"
# end

every 1.day, :at => '4:00 am' do
  runner "Group.calculate_scores"
end

# every 1440.minutes do
#   runner "MeteringPoint.calculate_scores"
# end

# every 1.day, :at => '10:00 am' do
#   runner "stream::previous_day_consumption"
# end


# every 3.hours do
#   runner "MyModel.some_process"
#   rake "my:rake:task"
#   command "/usr/bin/my_great_command"
# end

# every 1.day, :at => '4:30 am' do
#   runner "MyModel.task_to_run_at_four_thirty_in_the_morning"
# end

# every :hour do # Many shortcuts available: :hour, :day, :month, :year, :reboot
#   runner "SomeModel.ladeeda"
# end

# every :sunday, :at => '12pm' do # Use any day of the week or :weekend, :weekday
#   runner "Task.do_something_great"
# end

# every '0 0 27-31 * *' do
#   command "echo 'you can use raw cron syntax too'"
# end

# # run this task only on servers with the :app role in Capistrano
# # see Capistrano roles section below
# every :day, :at => '12:20am', :roles => [:app] do
#   rake "app_server:task"
# end
