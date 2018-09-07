require_relative '../organization'

Schemas::Constraints::Organization::Base = Schemas::Support.Form do
  required(:name).filled(:str?, max_size?: 64, min_size?: 4)
  optional(:description).filled(:str?, max_size?: 256)
  optional(:email).filled(:str?, :email?, max_size?: 64)
  optional(:phone).filled(:str?, :phone_number?, max_size?: 64)
  optional(:fax).filled(:str?, :phone_number?, max_size?: 64)
  optional(:website).filled(:str?, :url?, max_size?: 64)
  optional(:additional_legal_representation).filled(:str?, max_size?: 256)
end
