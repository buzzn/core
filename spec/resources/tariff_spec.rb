describe Contract::TariffResource do

  entity(:admin) { create(:account, :buzzn_operator) }
  entity(:localpool) { create(:group, :localpool) }
  entity(:tariff) { create(:tariff, group: localpool) }

  entity(:localpool_processing) do
    create(:contract, :localpool_processing,
           localpool: localpool,
           tariffs: [tariff])
  end

  let(:tariff_resource) { Admin::LocalpoolResource.all(admin).retrieve(localpool.id).tariffs.first }

  context 'without contracts' do
    before { tariff.contracts.delete_all }
    it 'can be deleted' do
      expect(tariff_resource.deletable).to eq true
    end
  end

  context 'with contract' do
    before do
      localpool_processing.tariffs << tariff unless localpool_processing.tariffs.include?(tariff)
    end
    it 'can not be deleted' do
      expect(tariff_resource.deletable).to eq false
    end
  end
end
