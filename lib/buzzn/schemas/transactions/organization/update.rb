require './app/models/organization/general.rb'
require_relative '../organization'
require_relative '../address/nested'

module Schemas::Transactions::Organization

  extend Schemas::Transactions::Address::Nested

  Update = Schemas::Support.Form(Schemas::Transactions::Update) do
    optional(:name).filled(:str?, max_size?: 64, min_size?: 4)
    optional(:description).filled(:str?, max_size?: 256)
    optional(:email).filled(:str?, :email?, max_size?: 64)
    optional(:phone).filled(:str?, :phone_number?, max_size?: 64)
    optional(:fax).filled(:str?, :phone_number?, max_size?: 64)
    optional(:website).filled(:str?, :url?, max_size?: 64)
  end

end
