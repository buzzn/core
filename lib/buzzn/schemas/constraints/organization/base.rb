require_relative '../organization'

Schemas::Constraints::Organization::Base = Schemas::Support.Form do
  required(:name).filled(:str?, max_size?: 64, min_size?: 4)
  optional(:description).maybe(:str?, max_size?: 256)
  optional(:email).maybe(:str?, :email?, max_size?: 64)
  optional(:phone).maybe(:str?, :phone_number?, max_size?: 64)
  optional(:fax).maybe(:str?, :phone_number?, max_size?: 64)
  optional(:website).maybe(:str?, :url?, max_size?: 64)
  optional(:additional_legal_representation).maybe(:str?, max_size?: 256)
end
