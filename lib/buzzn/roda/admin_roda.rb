require_relative 'base_roda'
module Admin
  class Roda < ::BaseRoda
    plugin :run_handler

    route do |r|

      r.run SwaggerRoda, :not_found=>:pass

      r.on 'localpools' do
        r.run LocalpoolRoda
      end
    end
  end
end
