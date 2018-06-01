require_relative 'base_roda'

class RegisterRoda < BaseRoda

  include Import.args[:env,
                      'transactions.ticker']

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

      r.get! 'ticker' do
        aggregated(ticker.(register).value)
      end

      r.get! 'readings' do
        # some mount points do not provide readings inside their
        # /registers/:id resource. returning nil means 404 response.
        register.readings rescue nil
      end
    end
  end

end
