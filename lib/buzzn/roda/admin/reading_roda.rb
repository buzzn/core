require_relative '../admin_roda'
class Admin::ReadingRoda < BaseRoda
  plugin :shared_vars
  plugin :created_deleted

  REGISTER = :register

  include Import.args[:env,
                      'transaction.create_reading']

  route do |r|

    register = shared[REGISTER]

    r.post! do
      created do
        create_reading.call(r.params,
                            resource: [register.method(:create_reading)])
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
        reading.delete
      end
    end
  end
end
