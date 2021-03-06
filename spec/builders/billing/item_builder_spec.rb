describe 'Builders::Billing::ItemBuilder' do

  describe 'from_contract' do

    before(:all) do
      create(:vat, amount: 0.19, begin_date: Date.new(2000, 1, 1))
    end

    let(:vat) do
      Vat.find(Date.new(2000, 01, 01))
    end

    let(:date_range) { Date.new(2018, 1, 1)...Date.new(2019, 1, 1) }
    let(:item) { Builders::Billing::ItemBuilder.from_contract(contract, register, date_range, contract.tariffs.first, vat) }

    describe 'date_range' do
      context 'when contract starts before date_range and hasn\'t ended' do
        let(:contract) { create(:contract, :localpool_gap, begin_date: date_range.first - 1.day, end_date: nil) }
        let(:register) { contract.register_meta.registers.first }
        it 'has the date_range\'s begin date' do
          expect(item.date_range).to eq(date_range.first...date_range.last)
        end
      end
      context 'when contract starts with date_range and hasn\'t ended' do
        let(:contract) { create(:contract, :localpool_gap, begin_date: date_range.first, end_date: nil) }
        let(:register) { contract.register_meta.registers.first }
        it 'has the date_range\'s begin date' do
          expect(item.date_range).to eq(date_range.first...date_range.last)
        end
      end
      context 'when contract starts in date_range and hasn\'t ended' do
        let(:contract) { create(:contract, :localpool_gap, begin_date: date_range.first + 1.day, end_date: nil) }
        let(:register) { contract.register_meta.registers.first }
        it 'has the contract\'s begin and end dates' do
          expect(item.date_range).to eq(contract.begin_date...date_range.last)
        end
      end
      context 'when contract starts and ends in date_range' do
        let(:contract) { create(:contract, :localpool_gap, begin_date: date_range.first + 1.day, end_date: date_range.last - 1.day) }
        let(:register) { contract.register_meta.registers.first }
        it 'has the contract\'s begin and end dates' do
          expect(item.date_range).to eq(contract.begin_date...contract.end_date)
        end
      end
      context 'when contract starts in and ends after date_range' do
        let(:contract) { create(:contract, :localpool_gap, begin_date: date_range.first + 1.day, end_date: date_range.last + 1.day) }
        let(:register) { contract.register_meta.registers.first }
        it 'has the contract\'s begin and date_range\'s end date' do
          expect(item.date_range).to eq(contract.begin_date...date_range.last)
        end
      end
    end

    describe 'type' do
      context 'when initialized with a regular powertaker contract' do
        let(:contract) { create(:contract, :localpool_powertaker) }
        let(:register) { contract.register_meta.registers.first }
        it 'has the type power_taker' do
          expect(item.contract_type).to eq('power_taker')
        end
      end
      context 'when initialized with a third party contract' do
        let(:contract) { create(:contract, :localpool_third_party) }
        let(:register) { contract.register_meta.registers.first }
        it 'has the type third_party' do
          expect(item.contract_type).to eq('third_party')
        end
      end
    end

    describe 'tariff' do
      context 'contract has no tariffs' do
        let(:contract) { create(:contract, :localpool_powertaker, tariffs: []) }
        let(:register) { contract.register_meta.registers.first }
        it 'has no tariff' do
          expect(item.tariff).to be_nil
        end
      end
      context 'contract has tariffs' do
        let(:contract) { create(:contract, :localpool_powertaker, :with_tariff) }
        let(:register) { contract.register_meta.registers.first }

        it 'has the last tariff' do
          expect(item.tariff).to eq(contract.tariffs.last)
          expect(item.tariff).not_to be_nil
        end
      end
    end

    describe 'begin_reading' do
      let(:register)        { create(:register, :real, readings: readings) }
      let(:contract)        { create(:contract, :localpool_powertaker, register_meta: register.meta) }

      context 'register has no reading for item begin date' do
        let(:readings) { [] }
        it 'has no begin_reading' do
          expect(item.begin_reading).to be_nil
        end
      end

      context 'register has a reading for item begin date' do
        let(:readings) { [build(:reading, date: date_range.first)] }
        it 'has a begin_reading' do
          expect(item.begin_reading).to eq(readings.first)
        end
      end
    end

    describe 'end_reading' do

      let(:register)        { create(:register, :real, readings: readings) }
      let(:contract)        { create(:contract, :localpool_powertaker, register_meta: register.meta) }

      context 'register has no reading for item end date' do
        let(:readings) { [] }
        it 'has no end_reading' do
          expect(item.end_reading).to be_nil
        end
      end

      context 'register has a reading for item end date' do
        let(:readings) { [build(:reading, date: date_range.last)] }
        it 'has an end_reading' do
          expect(item.end_reading).to eq(readings.first)
        end
      end
    end
  end

end
