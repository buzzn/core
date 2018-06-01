require_relative '../admin_roda'

module Admin
  class MeterRoda < BaseRoda

    include Import.args[:env, 'transactions.admin.meter.update_real']

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

        case meter.object
        when Meter::Real
          r.patch! do
            update_real.(resource: meter, params: r.params)
          end
        when Meter::Virtual
          nil # nothing to patch
        else
          raise "can not handle model: #{meter.class.model}"
        end

        r.on 'registers' do
          shared[RegisterRoda::CHILDREN] = meter.registers
          r.run RegisterRoda
        end

        case meter.object
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
