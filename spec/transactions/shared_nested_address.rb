shared_examples 'create without address' do |transaction, expected_class, params|

    entity(:result) do
      transaction.(params: params, resource: resource).value
    end

    it { expect(result.address).to be nil }
    it { expect(result).to be_a expected_class }

end

shared_examples 'create with address' do |transaction, expected_class, params|

    entity(:address) { {street: 'wallstreet', zip: '666', city: 'atlantis', country: 'IT'} }

    entity(:result) do
      transaction.(params: params.merge(address: address),
                   resource: resource).value
    end

    it { expect(result).to be_a expected_class }
    it { expect(result.address).to be_a AddressResource }

end
