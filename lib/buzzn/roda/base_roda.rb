require_relative 'common_roda'
require_relative 'helpers/serializer'
require_relative 'helpers/error_handler'
require_relative 'plugins/current_user'
require_relative 'plugins/terminal_verbs'
require_relative 'plugins/created_deleted'
require_relative 'plugins/aggregation'

require 'buzzn/data_result_set'
require 'buzzn/data_result_array'
require 'buzzn/data_point'
require 'buzzn/data_result'

require 'buzzn/db'


class BaseRoda < CommonRoda

  plugin :json_parser, parser: MultiJson.method(:load)

  plugin :json,
         :include_request=>true,
         :classes=>[Dry::Monads::Either::Right, Dry::Monads::Either::Left, NilClass, Array, Hash, Buzzn::DataResultSet, Buzzn::DataResultArray, Buzzn::DataResult, Buzzn::Resource::Base, Buzzn::Resource::Collection, Types::Datasource::Current, Types::CacheItem],
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
    session_inactivity_timeout Import.global('config.session_inactivity_timeout').to_i
    max_session_lifetime 86400 # 1 day

    jwt_secret Import.global('config.jwt_secret')
    json_response_error_status 401
  end
end
