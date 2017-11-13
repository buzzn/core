require_relative 'base_roda'
require_relative '../transactions/ticker'
require_relative '../transactions/register_chart'


class RegisterRoda < BaseRoda

  plugin :aggregation
  plugin :shared_vars

  route do |r|

    registers = shared[:registers]

    r.get! do
      rodauth.check_session_expiration
      registers
    end

    r.on :id do |id|

      register = registers.retrieve(id)

      r.get! do
        rodauth.check_session_expiration
        register
      end

      r.get! 'charts' do
        aggregated(
          Transactions::RegisterChart
            .for(register)
            .call(r.params).value
          )
        #aggregated(charts.call(r.params, resource: [register.method(:charts)]))
      end

      r.get! 'ticker' do
        aggregated(
          Transactions::Ticker
            .call(register).value
        )
      end

      r.get! 'readings' do
        # some mount points do not provide readings inside their
        # /registers/:id resource. returning nil means 404 response.
        register.readings rescue nil
      end
    end
  end
end
