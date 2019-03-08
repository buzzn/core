require_relative '../admin_roda'

class Admin::ReadingRoda < BaseRoda

  include Import.args[:env,
                      create: 'transactions.admin.reading.create',
                      request_create: 'transactions.admin.reading.request.create',
                      request_read: 'transactions.admin.reading.request.read',
                      delete: 'transactions.admin.reading.delete',
                     ]

  plugin :shared_vars

  REGISTER = :register

  route do |r|

    register = shared[REGISTER]

    r.post! do
      create.(resource: register, params: r.params)
    end

    r.on 'request' do

      r.on 'read' do
        r.post! do
          request_read.(resource: register, params: r.params)
        end
      end

      r.on 'create' do
        r.post! do
          request_create.(resource: register, params: r.params)
        end
      end

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
