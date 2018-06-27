require_relative '../localpool'
require_relative '../../address/nested'

module Schemas::Transactions::Admin::Localpool

  extend Schemas::Transactions::Address::Nested

  Update = Schemas::Support.Form(Schemas::Transactions::Update) do
    optional(:name).filled(:str?, max_size?: 64)
    optional(:description).filled(:str?, max_size?: 256)
    optional(:start_date).filled(:date?)
    optional(:show_object).filled(:bool?)
    optional(:show_production).filled(:bool?)
    optional(:show_energy).filled(:bool?)
    optional(:show_contact).filled(:bool?)
    optional(:show_display_app).filled(:bool?)
  end

end
