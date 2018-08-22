require_relative '../constraints'
Schemas::Constraints::Slug = Schemas::Support.Form do
  required(:namespace).filled(:str?, max_size?: 128)
  required(:basename).filled(:str?, max_size?: 256)
  required(:last_slug).filled(:str?, max_size?: 256)
  required(:count).filled(:int?)
end
