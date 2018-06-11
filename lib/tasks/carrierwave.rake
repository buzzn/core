require 'rubygems'
require 'rake'

namespace :carrierwave do
  desc 'delete uploaded carrierwave files'
  task :delete_uploads do
    FileUtils.rm_rf('public/uploads/')
  end
end
