class RegisterRoda < BaseRoda
  plugin :shared_vars

  route do |r|

    registers = shared[:localpool].registers

    r.get! do
      registers
    end

    r.on :id do |id|

      register = registers.retrieve(id)

      r.get! do
        register
      end

      r.get! 'readings' do
        register.readings
      end
    end
  end
end
