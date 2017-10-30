require_relative '../constraints'

Schemas::Constraints::Group = Buzzn::Schemas.Form do
  required(:name).filled(:str?, max_size?: 64)
  optional(:description).filled(:str?, max_size?: 256)
  optional(:start_date).filled(:date?)
  optional(:show_object).filled(:bool?)
  optional(:show_production).filled(:bool?)
  optional(:show_energy).filled(:bool?)
  optional(:show_contact).filled(:bool?)
end
