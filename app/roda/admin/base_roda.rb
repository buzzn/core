module Admin
  class BaseRoda < ::BaseRoda
    
    route do |r|

      r.on 'localpools' do
        r.run ::LocalpoolRoda
      end

    end
  end
end
