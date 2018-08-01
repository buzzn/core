describe Register do

  describe 'obis' do
    context 'when register is base' do
      it { expect(Register::Base.new.obis).to be_nil }
    end
    context 'when register is input' do
      it { expect(Register::Real.new(meta: Register::Meta.new(label: :consumption_common)).obis).to eq('1-1:1.8.0') }
    end
    context 'when register is output' do
      it { expect(Register::Real.new(meta: Register::Meta.new(label: :production_pv)).obis).to eq('1-1:2.8.0') }
    end
  end

  describe 'low_load_ability' do
    [Register::Base, Register::Real].each do |klass|
      it 'is false' do
        expect(klass.new.low_load_ability).to be(false)
      end
    end
  end

  describe 'pre_decimal_position' do
    [Register::Base, Register::Real].each do |klass|
      it 'is 6' do
        expect(klass.new.pre_decimal_position).to eq(6)
      end
    end
  end

  describe 'post_decimal_position' do
    [Register::Base, Register::Real].each do |klass|
      it 'is 1' do
        expect(klass.new.post_decimal_position).to eq(1)
      end
    end
  end

end
