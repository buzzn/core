require_relative 'common_roda'
require_relative 'helpers/serializer'
require_relative 'helpers/error_handler'
require_relative 'plugins/doorkeeper'
require_relative 'plugins/current_user'
require_relative 'plugins/terminal_verbs'
require_relative 'plugins/created_deleted'
require_relative 'plugins/aggregation'

class BaseRoda < CommonRoda

  use Rack::Session::Cookie, :secret => ENV['SECRET'] || 'my secret', :key => '_buzzn_session'

  plugin :json_parser, parser: MultiJson.method(:load)

  plugin :json,
         :include_request=>true,
         :classes=>[Dry::Monads::Either::Right, Dry::Monads::Either::Left, NilClass, Array, Hash, Buzzn::DataResultSet, Buzzn::DataResultArray, Buzzn::DataResult, Buzzn::Resource::Base, Buzzn::Resource::Collection],
         :serializer=> Buzzn::Roda::Serializer.new

  plugin :terminal_verbs

  plugin :doorkeeper

  plugin :current_user do |app|
    if app.doorkeeper_token
      Account::Base.where(id: app.doorkeeper_token.resource_owner_id).first
    else
      if (app.rodauth.valid_jwt? rescue false)
        Account::Base.where(id: app.rodauth.session[:account_id]).first
      end
    end
  end

  plugin :error_handler, &Buzzn::Roda::ErrorHandler.new

  plugin :drop_body

  plugin :empty_root

  plugin :default_headers,
    'Content-Type' => 'application/json',
  #  'Content-Security-Policy'=>"default-src 'self'",
  #  'Strict-Transport-Security'=>'max-age=16070400;',
    'X-Frame-Options' => 'deny',
    'X-Content-Type-Options' => 'nosniff',
    'X-XSS-Protection' => '1; mode=block',
    'Access-Control-Expose-Headers' => 'Authorization'

  plugin :rodauth, csrf: false do
  
    enable :session_expiration, :jwt

    session_expiration_redirect nil
    session_inactivity_timeout 900 # 15 minutes
    max_session_lifetime 86400 # 1 day

    db Buzzn::DB

    jwt_secret (ENV['JWT_SECRET'] || raise('missing JWT_SECRET in env'))
  end
end
