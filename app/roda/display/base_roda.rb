module Display
  class BaseRoda < ::BaseRoda
    
    route do |r|

      r.on 'groups' do
        r.run GroupRoda
      end

    end
  end
end
