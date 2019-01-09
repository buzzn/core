require_relative 'base'

module Register
  class Real < Base

    include Import.active_record['services.charts']

    belongs_to :meter, class_name: 'Meter::Real', foreign_key: :meter_id
    has_many :billing_items, class_name: 'BillingItem', foreign_key: :register_id

    #delegate :address, to: :meter, allow_nil: true

    def datasource
      Services::Datasource::Discovergy::Implementation::NAME
    end

    def billing_items_in_date_range(date_range)
      billing_items.in_date_range(date_range)
    end

  end
end
