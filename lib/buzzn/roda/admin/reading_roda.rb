require_relative '../admin_roda'

class Admin::ReadingRoda < BaseRoda

  include Import.args[:env,
                      'transactions.admin.reading.create',
                      'transactions.admin.reading.delete',
                     ]

  plugin :shared_vars

  REGISTER = :register

  route do |r|

    register = shared[REGISTER]

    r.post! do
      create.(resource: register, params: r.params)
    end

    readings = register.readings
    r.get! do
      readings
    end

    r.on :id do |id|
      reading = readings.retrieve(id)

      r.get! do
        reading
      end

      r.delete! do
        delete.(resource: reading)
      end
    end
  end

end
