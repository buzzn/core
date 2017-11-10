# coding: utf-8
describe Contract::TariffResource do

  entity(:admin) { Fabricate(:admin) }
  entity(:localpool) { Fabricate(:localpool) }
  entity(:tariff) { Fabricate(:tariff, group: localpool) }

  entity(:localpool_processing) { Fabricate(:localpool_processing_contract,
                                            localpool: localpool,
                                            tariffs: [tariff]) }

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
