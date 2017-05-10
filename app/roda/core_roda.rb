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

      r.on 'organizations' do
        r.run OrganizationRoda
      end

      r.on 'meters' do
        r.run MeterRoda
      end

      r.on 'registers' do
        r.run RegisterRoda
      end

      r.on 'contracts' do
        r.run ContractRoda
      end

      r.on 'users' do
        r.run UserRoda
      end

    end

    r.run Rails.application
  end
end
