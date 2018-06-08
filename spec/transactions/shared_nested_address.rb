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

shared_examples 'update without address' do |transaction, resource, params|

  entity(:result) do
    transaction.(params: params.merge(updated_at: localpool.reload.updated_at.as_json),
                 resource: resource).value
  end

  it { expect(result).to be_a resource.class }
  #   it { expect(result.name).to eq params.values. }
  it { expect(result.address).to be nil }

  context 'create address' do

    entity(:result2) do
      transaction.(params: {
                     updated_at: localpool.reload.updated_at.as_json,
                     address: {
                       street: 'wallstreet', zip: '666',
                       city: 'atlantis', country: 'IT',
                       updated_at: Date.new(0).as_json
                     }
                   },
                   resource: resource).value
    end

    it { expect(result2).to be_a resource.class }
#      it { expect(result2.name).to eq 'takakari' }
    it { expect(result2.address).to be_a AddressResource }

  end

end
