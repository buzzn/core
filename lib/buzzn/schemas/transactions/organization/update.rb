require './app/models/organization.rb'
require_relative '../organization'

Schemas::Transactions::Organization::Update = Schemas::Support.Form(Schemas::Transactions::Update) do
  optional(:name).filled(:str?, max_size?: 64, min_size?: 4)
  optional(:description).filled(:str?, max_size?: 256)
  optional(:email).filled(:str?, :email?, max_size?: 64)
  optional(:phone).filled(:str?, :phone_number?, max_size?: 64)
  optional(:fax).filled(:str?, :phone_number?, max_size?: 64)
  optional(:website).filled(:str?, :url?, max_size?: 64)
end
