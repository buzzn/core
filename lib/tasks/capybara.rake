require 'rubygems'
require 'rake'

namespace :capybara do
  desc "delete capybara screenshots and html"
  task :delete_screenshots do
    FileUtils.rm_rf("#{Rails.root}/tmp/capybara/")
  end
end