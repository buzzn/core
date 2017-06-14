require_relative 'base_roda'
module Display
  class Roda < BaseRoda
  
    route do |r|

      r.on 'groups' do
        r.run GroupRoda
      end

      r.run SwaggerRoda
    end
  end
end
