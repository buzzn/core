require_relative 'plugins/aggregation'
class RegisterRoda < BaseRoda

  include Import.args[:env,
                      'transaction.register_charts',
                      'service.current_power']

  plugin :aggregation
  plugin :shared_vars

  route do |r|

    registers = shared[:registers]

    r.get! do
      registers
    end

    r.on :id do |id|

      register = registers.retrieve(id)

      r.get! do
        register
      end

      r.get! 'charts' do
        aggregated(register_charts.call(r.params, register_charts: [register]))
      end

      r.get! 'ticker' do
        aggregated(current_power.for_register(register))
      end

      r.get! 'readings' do
        register.readings
      end
    end
  end
end
