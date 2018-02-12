require_relative 'base_roda'
module Admin
  class Roda < ::BaseRoda

    plugin :run_handler

    route do |r|

      r.run SwaggerRoda, :not_found=>:pass

      r.on 'localpools' do
        r.run LocalpoolRoda
      end

      rodauth.check_session_expiration

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
    end

  end
end
