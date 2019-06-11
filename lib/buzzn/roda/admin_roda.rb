require_relative 'base_roda'

module Admin
  class Roda < ::BaseRoda

    include Import.args[:env,
                        create_organization_market: 'transactions.admin.organization.create_organization_market',
                        update_organization_market: 'transactions.admin.organization.update_organization_market',
                        create_market_function:     'transactions.admin.market_function.create',
                        update_market_function:     'transactions.admin.market_function.update',
                        delete_market_function:     'transactions.admin.market_function.delete',
                       ]

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

          r.on 'market-functions' do

            r.post! do
              create_market_function.(resource: organization_market.market_functions, params: r.params, organization: organization_market.object)
            end

            r.on :mfid do |mfid|
              market_function = organization_market.market_functions.retrieve(mfid)

              r.patch! do
                update_market_function.(resource: market_function, params: r.params, organization: organization_market.object)
              end

              r.delete! do
                delete_market_function.(resource: market_function, params: r.params, organization: organization_market.object)
              end

              r.others!
            end

            r.others!

          end

          r.others!
        end

        r.others!
      end
    end

  end
end
