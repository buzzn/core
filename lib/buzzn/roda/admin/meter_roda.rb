require_relative '../admin_roda'
class Admin::MeterRoda < BaseRoda
  plugin :shared_vars

  include Import.args[:env,
                      'transaction.update_real_meter',
                      'transaction.update_virtual_meter']

  route do |r|

    meters = shared[:localpool].meters

    r.get! do
      meters.filter(r.params['filter'])
    end

    r.on :id do |id|
      meter = meters.retrieve(id)

      r.get! do
        meter
      end

      r.patch! do
        case meter.object
        when Meter::Real
          update_real_meter.call(r.params, resource: [meter])
        when Meter::Virtual
          update_virtual_meter.call(r.params, resource: [meter])
        else
          raise "unknown model: #{meter.class.model}"
        end
      end

      r.on 'registers' do
        shared[:registers] = meter.registers
        r.run Admin::RegisterRoda
      end
    end
  end
end
