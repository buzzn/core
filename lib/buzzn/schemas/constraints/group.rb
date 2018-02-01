require_relative '../constraints'

Schemas::Constraints::Group = Schemas::Support.Form do
  required(:name).filled(:str?, max_size?: 64, min_size?: 4)
  optional(:description).filled(:str?, max_size?: 256)
  optional(:start_date).filled(:date?)
  optional(:show_object).maybe(:bool?)
  optional(:show_production).maybe(:bool?)
  optional(:show_energy).maybe(:bool?)
  optional(:show_contact).maybe(:bool?)
  optional(:show_display_app).maybe(:bool?)
end
