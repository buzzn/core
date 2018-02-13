describe Register do

  entity!(:urbanstr) do
    Fabricate(:register_urbanstr88, meter: Fabricate(:output_meter))
  end

  entity! :register do
    easymeter_60051560 = Fabricate(:easymeter_60051560)
    easymeter_60051560.broker = Fabricate(:discovergy_broker, meter: easymeter_60051560)
    easymeter_60051560.output_register
  end

  it 'returns registers by label' do
    consumption = Register::Base.all.consumption.size
    production = Register::Base.all.production_pv.size
    3.times do
      Fabricate(:input_meter)
    end
    3.times do
      Fabricate(:output_meter)
    end
    expect(Register::Base.all.consumption.size).to eq consumption + 3
    expect(Register::Base.all.production_pv.size).to eq production + 3
    expect(Register::Base.all.by_labels(Register::Base.labels[:consumption], Register::Base.labels[:production_pv]).size).to eq consumption + production + 6
    expect(Register::Base.all.by_labels(Register::Base.labels[:grid_feeding], Register::Base.labels[:demarcation_pv]).size).to eq 0
    expect{ Register::Base.all.by_labels('something') }.to raise_error ArgumentError
  end

  describe 'obis' do
    context 'when register is base' do
      it { expect(Register::Base.new.obis).to be_nil }
    end
    context 'when register is real' do
      it { expect { Register::Real.new.obis }.to raise_error(RuntimeError, 'not implemented') }
    end
    context 'when register is input' do
      it { expect(Register::Input.new.obis).to eq('1-0:1.8.0') }
    end
    context 'when register is output' do
      it { expect(Register::Output.new.obis).to eq('1-0:2.8.0') }
    end
  end

  describe 'low_load_ability' do
    [Register::Base, Register::Real, Register::Input, Register::Output].each do |klass|
      it 'is false' do
        expect(klass.new.low_load_ability).to be(false)
      end
    end
  end

  describe 'pre_decimal_position' do
    [Register::Base, Register::Real, Register::Input, Register::Output].each do |klass|
      it 'is 6' do
        expect(klass.new.pre_decimal_position).to eq(6)
      end
    end
  end

  describe 'post_decimal_position' do
    [Register::Base, Register::Real, Register::Input, Register::Output].each do |klass|
      it 'is 1' do
        expect(klass.new.post_decimal_position).to eq(1)
      end
    end
  end

  describe 'name', :skip do
    let(:register) { create(:register, :real) }
    context 'when register has a market location' do
      before { register.create_market_location!(name: '1.OG links vorn') }
      it 'returns the name of the market location' do
        expect(register.name).to eq('1.OG links vorn')
      end
    end
    context 'when register has no market location' do
      context 'when register is persisted' do
        it 'returns the id' do
          expect(register.name).to eq("Register #{register.id}")
        end
      end
      context 'when register is not persisted' do
        it 'returns some info' do
          expect(build(:register, :real).name).to eq('Register (not persisted)')
        end
      end
    end
  end
end
