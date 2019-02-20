require_relative '../admin_roda'
require 'buzzn/utils/file'

module Admin
  class BillingCycleRoda < BaseRoda

    include Import.args[:env,
                        'transactions.admin.billing_cycle.create',
                        'transactions.admin.billing_cycle.generate_bars',
                        'transactions.admin.billing_cycle.generate_zip',
                        'transactions.admin.billing_cycle.update',
                        'transactions.admin.billing_cycle.delete',
                       ]

    plugin :shared_vars

    route do |r|

      localpool = shared[LocalpoolRoda::PARENT]

      r.post! do
        create.(resource: localpool, params: r.params)
      end

      billing_cycles = localpool.billing_cycles
      r.get! do
        billing_cycles
      end

      r.on :id do |id|
        billing_cycle = billing_cycles.retrieve(id)

        r.get! do
          billing_cycle
        end

        r.patch! do
          update.(resource: billing_cycle, params: r.params)
        end

        r.delete! do
          delete.(resource: billing_cycle)
        end

        r.on 'bars' do
          r.get! do
            generate_bars.(resource: billing_cycle, params: r.params)
          end
          r.others!
        end

        r.on 'zip' do
          r.get! do
            zip = generate_zip.(resource: billing_cycle, params: r.params)
            filename = Buzzn::Utils::File.sanitize_filename("#{localpool.name}_#{billing_cycle.name}.zip")
            byebug.byebug
            r.response.headers['Content-Type'] = 'application/zip'
            r.response.headers['Content-Disposition'] = "inline; filename=\"#{filename}\""
            r.response.write(zip.value!.string)
          end
          r.others!
        end

        r.on 'billings' do
          shared[:billings] = billing_cycle.billings
          r.run BillingRoda
        end
      end
    end

  end
end
