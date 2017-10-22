# coding: utf-8
describe Register::BaseResource do

  entity(:admin) { Fabricate(:admin) }
  entity(:localpool) { Fabricate(:localpool) }
  entity(:tariff) { Fabricate(:tariff, group: localpool) }

  entity(:localpool_processing) { Fabricate(:localpool_processing_contract,
                                            localpool: localpool,
                                            tariffs: [tariff]) }

  let(:resource) { Admin::LocalpoolResource.all(admin).retrieve(localpool.id).tariffs.first }

  it 'can be deleted' do
    tariff.update(contracts: nil)
    expect(resource.deletable).to eq true
  end

  it 'can not be deleted' do
    tariff.update(contracts: localpool_processing)
    expect(resource.deletable).to eq false
  end
end
