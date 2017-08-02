require_relative '../admin_roda'
module Admin
  class MeterRoda < BaseRoda
    plugin :shared_vars

    include Import.args[:env,
                        'transaction.update_real_meter',
                        'transaction.update_virtual_meter']

    route do |r|

      meters = shared[LocalpoolRoda::PARENT].meters

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

        case meter.object
        when Meter::Real
          r.on 'registers' do
            shared[RegisterRoda::CHILDREN] = meter.registers
            r.run RegisterRoda
          end
        when Meter::Virtual
          r.on 'formula-parts' do
            shared[FormulaPartRoda::CHILDREN] = meter.formula_parts
            r.run FormulaPartRoda
          end
        end
      end
    end
  end
end
