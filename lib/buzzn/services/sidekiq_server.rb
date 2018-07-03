require_relative '../services'
require 'sidekiq'

class Services::SidekiqServer

  extend Dry::DependencyInjection::Eager

  include Import[redis: 'services.redis_sidekiq']

  def initialize(**)
    super
    self.create
  end

  def create
    redis_conn = proc {
      redis
    }
    Sidekiq.configure_server do |config|
      config.redis = ConnectionPool.new(size: 30, &redis_conn)
    end
  end

  def self.new
    @instance ||= super().create
  end

  def self.current
    self.new
  end

end
