require_relative 'base_roda'

module Admin
  class Roda < ::BaseRoda

    include Import.args[:env,
                        'transactions.admin.organization.create_organization_market',
                        'transactions.admin.organization.update_organization_market']

    plugin :run_handler

    route do |r|

      r.run SwaggerRoda, :not_found=>:pass

      rodauth.check_session_expiration

      if current_user.nil?
        r.response.status = 401
        r.halt
      end

      r.on 'localpools' do
        r.run LocalpoolRoda
      end

      admin = AdminResource.new(current_user)

      r.on 'persons' do

        r.get! do
          admin.persons
        end

        r.get! :id do |id|
          admin.persons.retrieve(id)
        end
      end

      r.on 'organizations' do

        r.get! do
          admin.organizations
        end

        r.get! :id do |id|
          admin.organizations.retrieve(id)
        end
      end

      r.on 'organizations-market' do
        r.get! do
          admin.organization_markets
        end

        r.post! do
          create_organization_market.(resource: admin.organization_markets, params: r.params)
        end

        r.on :id do |id|
          organization_market = admin.organization_markets.retrieve(id)

          r.patch! do
            update_organization_market.(resource: organization_market, params: r.params)
          end

          r.others!
        end

        r.others!
      end
    end

  end
end
