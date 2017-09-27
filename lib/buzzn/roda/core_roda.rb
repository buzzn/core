require 'sequel'
class CoreRoda < Roda

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

  plugin :default_headers,
    'Content-Type'=>'application/json',
  #  'Content-Security-Policy'=>"default-src 'self'",
  #  'Strict-Transport-Security'=>'max-age=16070400;',
    'X-Frame-Options'=>'deny',
    'X-Content-Type-Options'=>'nosniff',
    'X-XSS-Protection'=>'1; mode=block'

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
