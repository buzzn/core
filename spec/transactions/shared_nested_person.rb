shared_examples 'create without person' do |transaction, expected_class, method, params|

  entity(:result) do
    transaction.(params: params, resource: resource).value
  end

  it { expect(result.send(method)).to be nil }
  it { expect(result).to be_a expected_class }

end

shared_examples 'create with person without address' do |transaction, expected_class, method, params|

  entity(:person) { {prefix: 'M', first_name: 'Frank', last_name: 'Zappa', preferred_language: 'de'} }

  entity(:result) do
    transaction.(params: params.merge(method => person),
                 resource: resource).value
  end

  it { expect(result.send(method)).to be_a PersonResource }
  it { expect(result.send(method).object.address).to be nil }
  it { expect(result).to be_a expected_class }

end

shared_examples 'create with person with address' do |transaction, expected_class, method, params|

  entity(:address) { {street: 'wallstreet', zip: '666', city: 'atlantis', country: 'IT'} }

  entity(:person) { {prefix: 'M', first_name: 'Frank', last_name: 'Zappa', preferred_language: 'de', address: address} }

  entity(:result) do
    transaction.(params: params.merge(method => person),
                 resource: resource).value
  end

  it { expect(result.send(method)).to be_a PersonResource }
  it { expect(result).to be_a expected_class }
  it { expect(result.send(method).address).to be_a AddressResource }

end
