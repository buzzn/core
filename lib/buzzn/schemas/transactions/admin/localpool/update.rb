require_relative '../localpool'
require_relative '../../address/nested'
require_relative '../billing_detail/update'

module Schemas::Transactions::Admin::Localpool

  extend Schemas::Transactions::Address::Nested

  Update = Schemas::Support.Form(Schemas::Transactions::Update) do
    configure do
      def valid_json?(json)
        true if JSON.parse(json)
      rescue JSON::ParserError
        false
      end
    end

    optional(:name).filled(:str?, max_size?: 64)
    optional(:description).maybe(:filled?, :str?, max_size?: 256)
    optional(:fake_stats).maybe(:filled?, :valid_json?)
    optional(:start_date).maybe(:filled?, :date?)
    optional(:show_object).filled(:bool?)
    optional(:show_production).filled(:bool?)
    optional(:show_energy).filled(:bool?)
    optional(:show_contact).filled(:bool?)
    optional(:show_display_app).filled(:bool?)
    optional(:generation).maybe(:filled?, :int?)
    # legacy
    optional(:legacy_power_taker_contract_buzznid).maybe(:str?, max_size?: 64)
    optional(:legacy_power_giver_contract_buzznid).maybe(:str?, max_size?: 64)
    optional(:billing_detail).schema(Schemas::Transactions::Admin::BillingDetail::Update)
  end

end
