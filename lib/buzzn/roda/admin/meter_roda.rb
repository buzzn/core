require_relative '../admin_roda'

module Admin
  class MeterRoda < BaseRoda

    include Import.args[:env,
                        'transactions.admin.meter.create_real',
                        'transactions.admin.meter.update_real',
                       ]

    plugin :shared_vars
    plugin :param_matchers

    route do |r|

      meters = shared[LocalpoolRoda::PARENT].meters
      meters_real = shared[LocalpoolRoda::PARENT].meters_real

      r.get! do
        meters.filter(r.params['filter'])
      end

      r.post!(:param=>'type') do |type|
        case type.to_s
        when 'real'
          create_real.(resource: meters_real, params: r.params)
        when 'virtual'
          r.response.status = 400
        end
      end

      r.post! do
        r.response.status = 400
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
