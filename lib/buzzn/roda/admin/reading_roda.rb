require_relative '../admin_roda'
require_relative '../../transactions/admin/reading/create'

class Admin::ReadingRoda < BaseRoda
  plugin :shared_vars

  REGISTER = :register

  route do |r|

    register = shared[REGISTER]

    r.post! do
      Transactions::Admin::Reading::Create
        .for(register)
        .call(r.params)
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
