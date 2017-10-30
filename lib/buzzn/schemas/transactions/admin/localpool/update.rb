require_relative '../localpool'

Schemas::Transactions::Admin::Localpool::Update = Buzzn::Schemas.Form(Schemas::Transactions::Update) do
  optional(:name).filled(:str?, max_size?: 64)
  optional(:description).filled(:str?, max_size?: 256)
  optional(:start_date).filled(:date?)
  optional(:show_object).filled(:bool?)
  optional(:show_production).filled(:bool?)
  optional(:show_energy).filled(:bool?)
  optional(:show_contact).filled(:bool?)
end
