shared_context 'billing cycle entities', :shared_context => :metadata do

  let(:start_date) { Date.new(2017,11,11)}
  let(:localpool) { create(:group, :localpool, start_date: start_date, gap_contract_customer: create(:person), fake_stats: { foo: 'bar' }) }

  let(:tariff) do
    tariff = create(:tariff, begin_date: localpool.start_date - 10, group: localpool)
    localpool.gap_contract_tariffs << tariff
    tariff
  end

  let!(:localpool_without_start_date) do
    localpool = create(:group, :localpool)
    localpool.start_date = nil
    localpool.save
    localpool
  end

  let(:account)            { Account::Base.where(person_id: user).first }
  let(:localpool_resource) { Admin::LocalpoolResource.all(account).retrieve(localpool.id) }
  let(:localpool_without_start_date_resource) { Admin::LocalpoolResource.all(account).retrieve(localpool_without_start_date.id) }

  3.times do |i|
    let!("contract_#{i+1}".to_sym) do
      create(:contract, :localpool_powertaker, localpool: localpool, tariffs: [tariff], begin_date: localpool.start_date + (i*13).days)
    end

    let!("install_reading_#{i+1}".to_sym) do
      contract = send("contract_#{i+1}")
      create(:reading, :setup, raw_value: 0, register: contract.register_meta.registers.first, date: contract.begin_date - 2.day)
    end
  end

end
