class CoreRoda < Roda

  # adds /heartbeat endpoint
  plugin :heartbeat

  route do |r|

    r.on 'api/v1' do

      r.on 'bank-accounts' do
        r.run BankAccountRoda
      end

      r.on 'groups' do
        r.run GroupRoda
      end
      
    end

    r.run Rails.application
  end
end
