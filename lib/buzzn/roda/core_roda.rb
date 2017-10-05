require 'sequel'
require_relative 'common_roda'

class CoreRoda < CommonRoda

  use Rack::CommonLogger, Logger.new(STDERR)

  use Rack::Session::Cookie, :secret => ENV['SECRET'] || 'my secret', :key => '_buzzn_session'

  use Rack::Cors, debug: Rails.env != 'production'  do
    allow do
      domains = %r(#{ENV['CORS']})
      origins *domains
      ['/api/*'].each do |path|
        resource path, headers: :any, methods: [:get, :post, :patch, :put, :delete, :options]
      end
    end
  end

  # adds /heartbeat endpoint
  plugin :heartbeat

  route do |r|

    r.on 'api' do
      r.on 'display' do
        r.run Display::Roda
      end

      r.on 'admin' do
        r.run Admin::Roda
      end
      
      r.on 'me' do
        r.run Me::Roda
      end
    end

    r.run Rails.application
  end
end
