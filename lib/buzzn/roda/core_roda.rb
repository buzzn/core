class CoreRoda < Roda

  use Rack::Cors, debug: Rails.env != 'production'  do
    allow do
      domains = case Rails.env
                when 'development', 'test'
                  %r(http://(localhost:[0-9]*|127.0.0.1:[0-9]*))
                when 'staging'
                  %r((https://(staging|develop)-[a-z0-9]*.buzzn.io|http://(localhost:[0-9]*|127.0.0.1:[0-9]*)))
                when 'production'
                  %r(https://[a-z0-9]*.buzzn.io)
                else
                  raise "unknown rails environment: #{Rails.env}"
                end
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
    end

    r.run Rails.application
  end
end
