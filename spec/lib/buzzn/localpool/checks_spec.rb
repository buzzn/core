describe Buzzn::Localpool::Checks do

  it 'finds object or error' do
    reading = Fabricate(:reading)
    date_of_first_reading = Buzzn::Localpool::Checks.find_object_or_error("no reading found for register") do
      Reading.by_register_id(reading.register_id).sort('timestamp': 1).first.timestamp
    end
    expect(date_of_first_reading).to eq reading.timestamp

    expect{
      date_of_first_reading = Buzzn::Localpool::Checks.find_object_or_error("no reading found for register") do
        Reading.by_register_id('blabla').sort('timestamp': 1).first.timestamp
      end
    }.to raise_error Buzzn::Localpool::CheckError
  end

  it 'checks last contract' do
    register = Fabricate(:input_meter).input_register
    localpool = Fabricate(:localpool)
    localpool.registers << register
    lptc = Fabricate(:localpool_power_taker_contract,
                      register: register,
                      begin_date: Date.new(2015, 1, 1),
                      end_date: Date.new(2015, 6, 1))
    lptc_2 = Fabricate(:localpool_power_taker_contract,
                      register: register,
                      begin_date: Date.new(2015, 6, 1),
                      end_date: Date.new(2015, 11, 1))
    all_contracts_on_register = [lptc, lptc_2]
    result = Buzzn::Localpool::MissingLsnCheckResultSet.new()

    all_contracts_on_register.size.times do |i|
      Buzzn::Localpool::Checks.check_last_contract(i, all_contracts_on_register[i].end_date, all_contracts_on_register, result, register)
    end

    expect(result.all_results.size).to eq 1
    expect(result.all_results.first.begin_date).to eq lptc_2.end_date
    expect(result.all_results.first.end_date).to eq nil
    expect(result.all_results.first.register).to eq register

    lptc_3 = Fabricate(:localpool_power_taker_contract,
                      register: register,
                      begin_date: Date.new(2015, 11, 1),
                      end_date: nil)
    all_contracts_on_register = [lptc, lptc_2, lptc_3]
    result = Buzzn::Localpool::MissingLsnCheckResultSet.new()

    all_contracts_on_register.size.times do |i|
      Buzzn::Localpool::Checks.check_last_contract(i, all_contracts_on_register[i].end_date, all_contracts_on_register, result, register)
    end

    expect(result.all_results.size).to eq 0
  end

  it 'checks middle contract' do
    register = Fabricate(:input_meter).input_register
    localpool = Fabricate(:localpool)
    localpool.registers << register
    lptc = Fabricate(:localpool_power_taker_contract,
                      register: register,
                      begin_date: Date.new(2015, 1, 1),
                      end_date: Date.new(2015, 5, 1))
    lptc_2 = Fabricate(:localpool_power_taker_contract,
                      register: register,
                      begin_date: Date.new(2015, 6, 1),
                      end_date: Date.new(2015, 11, 1))
    all_contracts_on_register = [lptc, lptc_2]
    result = Buzzn::Localpool::MissingLsnCheckResultSet.new()

    # detects the gap between the 2 contracts
    all_contracts_on_register.size.times do |i|
      Buzzn::Localpool::Checks.check_middle_contract(i, all_contracts_on_register[i].end_date, all_contracts_on_register, result, register)
    end

    expect(result.all_results.size).to eq 1
    expect(result.all_results.first.begin_date).to eq lptc.end_date
    expect(result.all_results.first.end_date).to eq lptc_2.begin_date
    expect(result.all_results.first.register).to eq register

    # detects nothing as there is no gap
    lptc_3 = Fabricate(:localpool_power_taker_contract,
                      register: register,
                      begin_date: Date.new(2015, 5, 1),
                      end_date: Date.new(2015, 6, 1))
    all_contracts_on_register = [lptc, lptc_3, lptc_2]
    result = Buzzn::Localpool::MissingLsnCheckResultSet.new()

    all_contracts_on_register.size.times do |i|
      Buzzn::Localpool::Checks.check_middle_contract(i, all_contracts_on_register[i].end_date, all_contracts_on_register, result, register)
    end

    expect(result.all_results.size).to eq 0

    # detects the overlap between the last 2 contracts
    lptc_4 = Fabricate(:localpool_power_taker_contract,
                      register: register,
                      begin_date: Date.new(2015, 10, 1),
                      end_date: nil)
    all_contracts_on_register = [lptc, lptc_3, lptc_2, lptc_4]
    result = Buzzn::Localpool::MissingLsnCheckResultSet.new()

    expect{
      all_contracts_on_register.size.times do |i|
        Buzzn::Localpool::Checks.check_middle_contract(i, all_contracts_on_register[i].end_date, all_contracts_on_register, result, register)
      end
    }.to raise_error Buzzn::Localpool::CheckError
  end

  it 'checks first contract' do
    register = Fabricate(:input_meter).input_register
    localpool = Fabricate(:localpool)
    localpool.registers << register
    lptc = Fabricate(:localpool_power_taker_contract,
                      register: register,
                      begin_date: Date.new(2015, 2, 1),
                      end_date: Date.new(2015, 5, 1))
    lptc_2 = Fabricate(:localpool_power_taker_contract,
                      register: register,
                      begin_date: Date.new(2015, 6, 1),
                      end_date: Date.new(2015, 11, 1))
    all_contracts_on_register = [lptc, lptc_2]
    result = Buzzn::Localpool::MissingLsnCheckResultSet.new()
    date_of_first_reading = Date.new(2015, 1, 1)

    # detects the earlier timestamp of first reading and first contract
    all_contracts_on_register.size.times do |i|
      Buzzn::Localpool::Checks.check_first_contract(i, date_of_first_reading, all_contracts_on_register[i].begin_date, result, register)
    end

    expect(result.all_results.size).to eq 1
    expect(result.all_results.first.begin_date).to eq date_of_first_reading
    expect(result.all_results.first.end_date).to eq lptc.begin_date
    expect(result.all_results.first.register).to eq register

    # detects nothing
    result = Buzzn::Localpool::MissingLsnCheckResultSet.new()
    date_of_first_reading = Date.new(2015, 2, 1)

    all_contracts_on_register.size.times do |i|
      Buzzn::Localpool::Checks.check_first_contract(i, date_of_first_reading, all_contracts_on_register[i].begin_date, result, register)
    end

    expect(result.all_results.size).to eq 0
  end

  it 'checks for missing_lsn_contracts' do
    localpool = Fabricate(:localpool_sulz_with_registers_and_readings)
    result = Buzzn::Localpool::Checks.check_missing_lsn_contracts(localpool)

    expect(result.all_results.size).to eq 0

    osc = Contract::OtherSupplier.first
    osc.destroy

    result = Buzzn::Localpool::Checks.check_missing_lsn_contracts(localpool)

    expect(result.all_results.size).to eq 1
    expect(result.all_results.first.begin_date).to eq osc.begin_date
    expect(result.all_results.first.end_date).to eq osc.end_date + 1.day
    expect(result.all_results.first.register).to eq osc.register

    # no contract at this register anymore
    osc.register.contracts.first.destroy

    result = Buzzn::Localpool::Checks.check_missing_lsn_contracts(localpool)

    expect(result.all_results.size).to eq 1
    expect(result.all_results.first.begin_date).to eq osc.begin_date
    expect(result.all_results.first.end_date).to eq nil
    expect(result.all_results.first.register).to eq osc.register
  end

  it 'assigns new LSN to register' do
    localpool = Fabricate(:localpool_sulz_with_registers_and_readings)
    customer = localpool.localpool_processing_contract.customer
    osc = Contract::OtherSupplier.first
    osc.destroy

    Buzzn::Localpool::Checks.assign_default_lsn(customer, osc.register, osc.begin_date, osc.end_date)

    result = Buzzn::Localpool::Checks.check_missing_lsn_contracts(localpool)

    expect(result.all_results.size).to eq 0
  end
end