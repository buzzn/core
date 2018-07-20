require_relative 'base'

module Register
  class Real < Base

    include Import.active_record['services.charts']

    belongs_to :meter, class_name: 'Meter::Real', foreign_key: :meter_id

    delegate :address, to: :meter, allow_nil: true

    def datasource
      Services::Datasource::Discovergy::Implementation::NAME
    end

  end
end
