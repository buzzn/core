shared_examples 'create without address' do |transaction, expected_class, params|

  entity(:result) do
    transaction.(params: params, resource: resource).value!
  end

  it { expect(result.address).to be nil }
  it { expect(result).to be_a expected_class }

end

shared_examples 'create with address' do |transaction, expected_class, params|

  entity(:address) { {street: 'wallstreet', zip: '666', city: 'atlantis', country: 'IT'} }

  entity(:result) do
    transaction.(params: params.merge(address: address),
                 resource: resource).value!
  end

  it { expect(result).to be_a expected_class }
  it { expect(result.address).to be_a AddressResource }

end

shared_examples 'update with address' do |transaction, resource_name, params|

  entity(:resource) { send(resource_name) }
  entity(:object) do
    o = resource.object
    o.update(address: create(:address))
    o.reload
  end

  entity!(:result) do
    transaction.(params: params.merge(updated_at: object.updated_at.as_json),
                 resource: resource).value!
  end

  it { expect(result).to be_a resource.class }
  params.each do |k, v|
    it { expect(result.send(k)).to eq(v) }
  end
  it { expect(result.address).to be_a AddressResource }

  context 'update address' do

    entity(:result2) do
      transaction.(params: {
                     updated_at: object.reload.updated_at.as_json,
                     address: {
                       street: 'behind the black door',
                       updated_at: object.address.updated_at.as_json
                     }
                   },
                   resource: resource).value!
    end

    it { expect(result2).to be_a resource.class }
    it { expect(result2.address).to be_a AddressResource }
    it { expect(result2.address.street).to eq 'behind the black door' }

  end

end

shared_examples 'update without address' do |transaction, resource_name, params|

  entity(:resource) { send(resource_name) }
  entity(:object) do
    o = resource.object
    o.update(address: nil)
    o.reload
  end

  entity(:result) do
    transaction.(params: params.merge(updated_at: object.updated_at.as_json),
                 resource: resource).value!
  end

  it { expect(result).to be_a resource.class }
  params.each do |k, v|
    it { expect(result.send(k)).to eq(v) }
  end
  it { expect(result.address).to be nil }

  context 'create address' do

    entity!(:result2) do
      transaction.(params: {
                     updated_at: object.reload.updated_at.as_json,
                     address: {
                       street: 'wallstreet', zip: '666',
                       city: 'atlantis', country: 'IT',
                     }
                   },
                   resource: resource).value!
    end

    it { expect(result2).to be_a resource.class }
    it { expect(result2.address.street).to eq 'wallstreet' }
    it { expect(result2.address).to be_a AddressResource }

  end

end
