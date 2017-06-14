require_relative '../admin_roda'
class Admin::MeterRoda < BaseRoda
  plugin :shared_vars

  route do |r|

    meters = shared[:localpool].meters

    r.get! do
      meters.filter(r.params['filter'])
    end

    r.get! :id do |id|
      meters.retrieve(id)
    end
  end
end
