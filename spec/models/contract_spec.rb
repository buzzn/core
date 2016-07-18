# coding: utf-8
describe "Contract Model" do

  it 'filters contract' do
    Fabricate(:discovergy)
    contract = Fabricate(:mpoc_stefan)
    Fabricate(:mpoc_karin)

    [contract.tariff, contract.mode, contract.signing_user,
     contract.username].each do |val|
      
      [val, val.upcase, val.downcase, val[0..40], val[-40..-1]].each do |value|
        contracts = Contract.filter(value)
        expect(contracts.sort{|x,y| x.username <=> y.username}.last).to eq contract
      end
    end
  end


  it 'can not find anything' do
    Fabricate(:discovergy)
    Fabricate(:mpoc_justus)
    contracts = Contract.filter('Der Clown ist müde und geht nach Hause.')
    expect(contracts.size).to eq 0
  end


  it 'filters contract with no params' do
    Fabricate(:discovergy)
    Fabricate(:mpoc_stefan)
    Fabricate(:mpoc_karin)

    contracts = Contract.filter(nil)
    expect(contracts.size).to eq 2
  end
end
