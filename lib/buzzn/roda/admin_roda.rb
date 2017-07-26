require_relative 'base_roda'
module Admin
  class Roda < ::BaseRoda
    plugin :run_handler

    route do |r|

      r.run SwaggerRoda, :not_found=>:pass

      # do not even step into the tree unless we have a current_user
      #if current_user.nil?
      #  r.response.status = 401
      #  r.halt
      #end

      r.on 'localpools' do
        r.run LocalpoolRoda
      end

      r.on 'me' do
        r.run MeRoda
      end
    end
  end
end
