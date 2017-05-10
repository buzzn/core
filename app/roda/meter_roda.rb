class MeterRoda < BaseRoda

  route do |r|

    r.get! :id do |id|
      Meter::BaseResource.retrieve(current_user, id)
    end

    r.get! 'real', :id, 'registers' do |id|
      Meter::RealResource
              .retrieve(current_user, id)
              .registers
    end

    r.get! 'virtual', :id, 'register' do |id|
      Meter::VirtualResource
              .retrieve(current_user, id)
              .register!
    end
  end
end
