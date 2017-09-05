# coding: utf-8
describe "Bank Model" do

  let(:dir) { 'db/banks' }
  let(:first_file) { File.join(dir, "BLZ_20160606.txt") }
  let(:second_file) { File.join(dir, "BLZ_20160905.txt") }

  before do
    Bank.update_from(first_file)
  end

  it 'updates data idempotent' do
    first = Bank.all.each { |b| b.attributes.to_json }
    Bank.update_from(first_file)
    second = Bank.all.each { |b| b.attributes.to_json }
    expect(second).to eq first
  end
  
  it 'updates data same as fresh import' do
    Bank.update_from(second_file)
    first = Bank.all.each { |b| b.attributes.to_json }
    Bank.delete_all
    Bank.update_from(second_file)
    second = Bank.all.each { |b| b.attributes.to_json }
    expect(second).to match_array first
  end

  it 'finds bank' do
    # via bic
    bank = Bank.find_by_bic('FDDODEMM')
    expect(bank.zip).to eq "80335"
    expect(bank.place).to eq "München"

    second = Bank.find_by_bic(' FDDODEMM')
    expect(second).to eq bank

    # via iban
    second = Bank.find_by_iban('DE2770022200123456789')
    expect(second).to eq bank
    
    second = Bank.find_by_iban('DE27 7002 2200123456789 ')
    expect(second).to eq bank
    
    # mutliple bic entries
    bank = Bank.find_by_bic('COBADEBBXXX')
    expect(bank.zip).to eq "10891"
    expect(bank.place).to eq "Berlin"
    
    second = Bank.find_by_bic('COBADEBB')
    expect(second).to eq bank
  end
end
