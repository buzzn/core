require_relative 'base_roda'

module Admin
  class Roda < ::BaseRoda

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

      r.get! 'organizations' do
        admin.organizations
      end
      r.get! 'organization_markets' do
        admin.organization_markets
      end
    end

  end
end
