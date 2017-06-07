module Admin
  class BaseRoda < ::BaseRoda
    
    route do |r|

      r.on 'localpools' do
        r.run LocalpoolRoda
      end

      r.on 'me' do
        r.run ::MeRoda
      end
    end
  end
end
