require_relative 'common_roda'
require_relative 'helpers/serializer'
require_relative 'helpers/error_handler'
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

  plugin :current_user do |app|
    if (app.rodauth.valid_jwt? rescue false)
      Account::Base.where(id: app.rodauth.session[:account_id]).first
    end
  end

  plugin :error_handler, &Buzzn::Roda::ErrorHandler.new

  plugin :drop_body

  plugin :empty_root

  plugin :rodauth, csrf: false, json: :only do
  
    enable :session_expiration, :jwt

    db Buzzn::DB

    session_expiration_redirect nil
    session_inactivity_timeout 15 * 60 # 15 minutes
    max_session_lifetime 86400 # 1 day

    jwt_secret (ENV['JWT_SECRET'] || raise('missing JWT_SECRET in env'))
    json_response_error_status 401
  end
end
