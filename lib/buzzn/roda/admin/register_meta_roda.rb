require_relative '../admin_roda'

module Admin
  class RegisterMetaRoda < BaseRoda

    plugin :shared_vars

    route do |r|

      register_metas = shared[LocalpoolRoda::PARENT].register_metas

      r.get! do
        register_metas
      end

      r.on :id do |id|
        register_meta = register_metas.retrieve(id)

        r.get! do
          register_meta
        end

        r.patch! do
          Transactions::Admin::Register::UpdateMeta.(
            resource: register_meta, params: r.params
          )
        end

        r.others!

      end
    end

  end
end
