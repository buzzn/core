require_relative '../admin_roda'
require_relative '../../transactions/admin/register/update_real'
require_relative '../../transactions/admin/register/update_virtual'

class Admin::RegisterRoda < BaseRoda

  CHILDREN = :registers

  plugin :aggregation
  plugin :shared_vars

  route do |r|

    registers = shared[CHILDREN]

    r.get! do
      registers
    end

    r.on :id do |id|

      register = registers.retrieve(id)

      r.get! do
        register
      end

      r.patch! do
        case register.object
        when Register::Real
          Transactions::Admin::Register::UpdateReal.(
            resource: register, params: r.params
          )
        when Register::Virtual
          Transactions::Admin::Register::UpdateVirtual.(
            resource: register, params: r.params
          )
        else
          raise "unknown model: #{register.class.model}"
        end
      end

      r.get! 'ticker' do
        aggregated(
          Transactions::Ticker.(register).value
        )
      end

      r.on 'readings' do
        shared[Admin::ReadingRoda::REGISTER] = register
        r.run Admin::ReadingRoda
      end
    end
  end

end
