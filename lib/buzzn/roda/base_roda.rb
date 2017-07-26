require_relative 'helpers/serializer'
require_relative 'helpers/error_handler'
require_relative 'plugins/doorkeeper'
require_relative 'plugins/current_user'
require_relative 'plugins/terminal_verbs'
require_relative 'plugins/created_deleted'
require_relative 'plugins/aggregation'

class BaseRoda < Roda

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
      Account::Base.where(id: app.session['account_id']).first
    end
  end

  plugin :error_handler, &Buzzn::Roda::ErrorHandler.new

  plugin :drop_body

  plugin :empty_root

end
