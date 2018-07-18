describe Register do

  describe 'obis' do
    context 'when register is base' do
      it { expect(Register::Base.new.obis).to be_nil }
    end
    context 'when register is real' do
      it { expect { Register::Real.new.obis }.to raise_error(RuntimeError, 'not implemented') }
    end
    context 'when register is input' do
      it { expect(Register::Input.new.obis).to eq('1-1:1.8.0') }
    end
    context 'when register is output' do
      it { expect(Register::Output.new.obis).to eq('1-1:2.8.0') }
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

  describe 'name' do
    context 'when register has a market location' do
      let(:register) { create(:register, :real, :with_market_location) }
      it 'returns the name of the market location' do
        expect(register.name).to eq(register.market_location.name)
        expect(register.name).not_to be_nil
      end
    end
    context 'when register has no market location' do
      let(:register) { create(:register, :real) }
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
