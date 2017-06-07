class RegisterRoda < BaseRoda

  include Import.args[:env,
                      'transaction.charts']

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
        aggregated(charts.call(r.params, resource: [register.method(:charts)]))
      end

      r.get! 'ticker' do
        aggregated(register.ticker)
      end

      r.get! 'readings' do
        # some mount points do not provide readings inside their
        # /registers/:id resource. returning nil means 404 response.
        register.readings rescue nil
      end
    end
  end
end
