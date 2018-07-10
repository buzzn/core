shared_examples 'create without person' do |transaction, expected_class, method, params|

  entity(:result) do
    transaction.(params: params, resource: resource).value!
  end

  it { expect(result.send(method)).to be nil }
  it { expect(result).to be_a expected_class }

end

shared_examples 'create with person without address' do |transaction, expected_class, method, params|

  entity(:person) { {prefix: 'M', first_name: 'Frank', last_name: 'Zappa', preferred_language: 'de'} }

  entity(:result) do
    transaction.(params: params.merge(method => person),
                 resource: resource).value!
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
                 resource: resource).value!
  end

  it { expect(result.send(method)).to be_a PersonResource }
  it { expect(result).to be_a expected_class }
  it { expect(result.send(method).address).to be_a AddressResource }

end

shared_examples 'update without person' do |transaction, resource_name, method, params|

  entity(:resource) { send(resource_name) }

  entity(:object) do
    o = resource.object
    o.update!(method => nil)
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
  it { expect(result.send(method)).to be nil }

  context 'create person' do

    entity!(:result2) do
      transaction.(params: {
                     updated_at: object.reload.updated_at.as_json,
                     method => {
                       prefix: 'M',
                       first_name: 'Elvis',
                       last_name: 'Presely',
                       preferred_language: 'de'
                     }
                   },
                   resource: resource).value!
    end

    it { expect(result2).to be_a resource.class }
    it { expect(result2.send(method).first_name).to eq 'Elvis' }
    it { expect(result2.send(method)).to be_a PersonResource }

  end
end

shared_examples 'update with person without address' do |transaction, resource_name, method, params|

  entity(:resource) { send(resource_name) }
  entity(:object) do
    o = resource.object
    o.update!(method => create(:person))
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
  it { expect(result.send(method)).to be_a PersonResource }

  context 'update person' do

    entity(:result2) do
      transaction.(params: {
                     updated_at: object.reload.updated_at.as_json,
                     method => {
                       first_name: 'Jimi',
                       last_name: 'Hendrix',
                       updated_at: object.send(method).updated_at.as_json
                     }
                   },
                   resource: resource).value!
    end

    it { expect(result2).to be_a resource.class }
    it { expect(result2.send(method)).to be_a PersonResource }
    it { expect(result2.send(method).first_name).to eq 'Jimi' }
    it { expect(result2.send(method).last_name).to eq 'Hendrix' }

  end

end

shared_examples 'update with person with address' do |transaction, resource_name, method, params|

  entity(:resource) { send(resource_name) }
  entity(:object) do
    o = resource.object
    o.update!(method => create(:person))
    o.reload
  end

  entity!(:address) { object.address }

  entity!(:result) do
    transaction.(params: params.merge(updated_at: object.updated_at.as_json),
                 resource: resource).value!
  end

  it { expect(result).to be_a resource.class }
  params.each do |k, v|
    it { expect(result.send(k)).to eq(v) }
  end
  it { expect(result.send(method)).to be_a PersonResource }

  context 'update person and update address' do

    entity!(:address2) do
      address = create(:address)
      object.send(method).update!(address: address)
      address
    end

    entity(:result2) do
      transaction.(params: {
                     updated_at: object.reload.updated_at.as_json,
                     method => {
                       first_name: 'Jimi',
                       last_name: 'Hendrix',
                       updated_at: object.send(method).reload.updated_at.as_json,
                       address: {
                         street: 'paint it black',
                         updated_at: address2.reload.updated_at.as_json
                       }
                     }
                   },
                   resource: resource).value!
    end

    it { expect(result2).to be_a resource.class }
    it { expect(result2.send(method)).to be_a PersonResource }
    it { expect(result2.send(method).first_name).to eq 'Jimi' }
    it { expect(result2.send(method).last_name).to eq 'Hendrix' }
    it { expect(result2.send(method).address).to be_a AddressResource }
    it { expect(result2.send(method).address.street).to eq 'paint it black' }

  end

  context 'update person and create address' do

    entity!(:address3) { object.send(method).update!(address: nil) }

    entity(:result3) do
      transaction.(params: {
                     updated_at: object.reload.updated_at.as_json,
                     method => {
                       first_name: 'Bill',
                       last_name: 'Gates',
                       updated_at: object.send(method).reload.updated_at.as_json,
                       address: {
                         street: 'wallstreet', zip: '666',
                         city: 'atlantis', country: 'IT'
                       }
                     }
                   },
                   resource: resource).value!
    end

    it { expect(result3).to be_a resource.class }
    it { expect(result3.send(method)).to be_a PersonResource }
    it { expect(result3.send(method).first_name).to eq 'Bill' }
    it { expect(result3.send(method).last_name).to eq 'Gates' }
    it { expect(result3.send(method).address).to be_a AddressResource }
    it { expect(result3.send(method).address.street).to eq 'wallstreet' }

  end

end
