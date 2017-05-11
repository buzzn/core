class CoreRoda < Roda

  # adds /heartbeat endpoint
  plugin :heartbeat

  route do |r|

    r.on 'api/v1' do

      r.on 'me' do
        r.run MeRoda
      end

      r.on 'bank-accounts' do
        r.run BankAccountRoda
      end

      r.on 'groups' do
        r.run GroupRoda
      end

      r.on 'organizations' do
        r.run OrganizationLegacyRoda
      end

      r.on 'meters' do
        r.run MeterLegacyRoda
      end

      r.on 'registers' do
        r.run RegisterLegacyRoda
      end

      r.on 'contracts' do
        r.run ContractLegacyRoda
      end

      r.on 'users' do
        r.run UserLegacyRoda
      end
    end

    r.run Rails.application
  end
end
