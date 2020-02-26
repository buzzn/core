require_relative '../admin_roda'
require 'time'

class Admin::ElectricityLabellingRoda < BaseRoda

  include Import.args[:env,
                      create_electricity_labelling:
                        'transactions.admin.report.create_electricity_labelling'
                     ]

  plugin :shared_vars

  route do |r|

    localpool = shared[:localpool]

    r.post! do
      create_electricity_labelling.(resource: localpool, params: r.params)
    end
  end

  end
