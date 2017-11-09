describe Operations::Validation do

  let(:schema) { Dry::Validation.Schema {required(:a).filled(:int?)} }

  it 'validates input successfully' do
    input = {a: 123}
    result = subject.call(input, schema)
    expect(result).to be_a Dry::Monads::Either::Right
    expect(result.value).to eq input
  end

  it 'does not validate the input' do
    input = {a: '123'}
    expect{ subject.call(input, schema) }.to raise_error Buzzn::ValidationError
  end
end
