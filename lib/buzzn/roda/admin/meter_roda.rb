require_relative '../admin_roda'
require_relative '../../transactions/admin/meter/update_real'
require_relative '../../transactions/admin/meter/update_virtual'

module Admin
  class MeterRoda < BaseRoda
    plugin :shared_vars

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
            Transactions::Admin::Meter::UpdateReal.for(meter).call(r.params)
          when Meter::Virtual
            Transactions::Admin::Meter::UpdateVirtual.for(meter).call(r.params)
          else
            raise "can not handle model: #{meter.class.model}"
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
