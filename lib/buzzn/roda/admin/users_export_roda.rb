require_relative '../admin_roda'
require_relative '../plugins/aggregation'

module Admin
  class UserExportRoda < BaseRoda

    include Import.args[:env,
                       'transactions.admin.power_taker_export'
                      ]

    plugin :shared_vars
    plugin :aggregation

    route do |r|
      localpools = LocalpoolResource.all(current_user)
      s = power_taker_export.(localpools: localpools).value!
      s[:get_local_power_takers]
    end
  end
end
