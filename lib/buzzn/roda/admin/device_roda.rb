require_relative '../admin_roda'

module Admin
  class DeviceRoda < BaseRoda

    include Import.args[:env,
                        'transactions.admin.device.create',
                        'transactions.admin.device.update',
                        'transactions.admin.device.delete']

    plugin :shared_vars

    route do |r|
      devices = shared[LocalpoolRoda::PARENT].devices

      r.get! { devices }
      r.post! { create.(resource: devices, params: r.params) }

      r.on :id do |id|
        device = devices.retrieve(id)

        r.get! { device }
        r.patch! { update.(resource: device, params: r.params) }
        r.delete! { delete.(resource: device) }

      end

    end

  end
end
