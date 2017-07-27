describe Buzzn::IncludeParser do

  it 'parses simple include strings' do
    expect(Buzzn::IncludeParser.parse(nil))
      .to eq({})
    expect(Buzzn::IncludeParser.parse(''))
      .to eq({})
    expect(Buzzn::IncludeParser.parse('address'))
      .to eq(address: {})
    expect(Buzzn::IncludeParser.parse('address, contact'))
      .to eq(address: {}, contact: {})
  end

  it 'parses nested include string' do
    expect(Buzzn::IncludeParser.parse('address: contact'))
      .to eq(address: {contact: {}})
    expect(Buzzn::IncludeParser.parse('address: [contact, account]'))
      .to eq(address: {contact: {}, account: {}})
    expect(Buzzn::IncludeParser.parse('contract, address: contact'))
      .to eq(contract: {}, address: {contact: {}})
    expect(Buzzn::IncludeParser.parse('contract, address: [contact, account]'))
      .to eq(contract: {}, address: {contact: {}, account: {}})
    expect(Buzzn::IncludeParser.parse('address: contact, contract'))
      .to eq(address: {contact: {}}, contract: {})
    expect(Buzzn::IncludeParser.parse('address: [contact, account], contract'))
      .to eq(address: {contact: {}, account: {}}, contract: {})
  end

  it 'parses complex include strings' do
    expect(Buzzn::IncludeParser.parse('address: contact: contract'))
      .to eq(address: {contact: {contract: {}}})
    expect(Buzzn::IncludeParser.parse('address: [contact, account: contract]'))
      .to eq(address: {contact: {}, account: {contract: {}}})
    expect(Buzzn::IncludeParser.parse('contractor:[address,bank_account],customer:[address,bank_account,contact:address],tariffs,payments'))
      .to eq(contractor: {address: {}, bank_account: {}}, customer: {address: {}, bank_account: {}, contact: {address: {}}}, tariffs: {}, payments: {})
    expect(Buzzn::IncludeParser.parse('contractor:[address,bank_account],customer:[address,bank_account,contact:[address]],tariffs,payments'))
      .to eq(contractor: {address: {}, bank_account: {}}, customer: {address: {}, bank_account: {}, contact: {address: {}}}, tariffs: {}, payments: {})
  end

end
