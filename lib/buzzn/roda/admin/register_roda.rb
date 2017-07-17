require_relative '../admin_roda'
class Admin::RegisterRoda < BaseRoda
  plugin :shared_vars

  include Import.args[:env,
                      'transaction.update_real_register',
                      'transaction.update_virtual_register']

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
      
      r.patch! do
        case register.object
        when Register::Real
          update_real_register.call(r.params, resource: [register])
        when Register::Virtual
          update_virtual_register.call(r.params, resource: [register])
        else
          raise "unknown model: #{register.class.model}"
        end
      end
    end
  end
end
