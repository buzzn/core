class CoreRoda < Roda

  use Rack::Cors, debug: ENV['RAILS_ENV'] != 'production'  do
    allow do
      domains = case ENV['RAILS_ENV']
                when 'development', 'test'
                  %r(http://(localhost:[0-9]*|127.0.0.1:[0-9]*))
                when 'staging'
                  %r((https://(staging|develop)-[a-z0-9]*.buzzn.io|http://(localhost:[0-9]*|127.0.0.1:[0-9]*)))
                when 'production'
                  %r(https://[a-z0-9]*.buzzn.io)
                else
                  raise "unknown rails environment: #{ENV['RAILS_ENV']}"
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
        r.run Display::BaseRoda
      end

      r.on 'admin' do
        r.run Admin::BaseRoda
      end

      # TODO remove thos deprecated paths

      r.on 'v1' do

        r.on 'aggregate' do
          r.run AggregateRoda
        end

        r.on 'me' do
          r.run MeRoda
        end

        r.on 'bank-accounts' do
          r.run BankAccountRoda
        end

        r.on 'groups' do
          r.run GroupRoda
        end

        r.on 'organizations' do
          r.run OrganizationLegacyRoda
        end

        r.on 'meters' do
          r.run MeterLegacyRoda
        end

        r.on 'registers' do
          r.run RegisterLegacyRoda
        end

        r.on 'contracts' do
          r.run ContractLegacyRoda
        end

        r.on 'users' do
          r.run UserLegacyRoda
        end
      end
    end

    r.run Rails.application
  end
end
