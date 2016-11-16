namespace :cache do

  task :update => :environment do
    Group.update_chart_cache
    Register.update_chart_cache
  end

end