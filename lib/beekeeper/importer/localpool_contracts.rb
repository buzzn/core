class Beekeeper::Importer::LocalpoolContracts

  attr_reader :logger

  def initialize(logger)
    @logger = logger
    logger.level = Import.global('config.log_level')
  end

  def run(localpool, powertaker_contracts, third_parties, registers, tariffs, warnings)
    powertaker_contracts.each do |contract|
      begin
        ActiveRecord::Base.transaction do
          customer = find_or_create_customer(contract[:powertaker])
          create_contract(localpool, customer, contract, registers, tariffs)
        end
      rescue => e
        logger.error("#{e} (meter buzznid: #{contract[:buzznid]})")
        e.backtrace.each { |row| logger.error("  #{row}") }
      end
    end
    third_parties.each do |contract|
      begin
        ActiveRecord::Base.transaction do
          create_third_party_contract(localpool, contract, registers, warnings)
        end
      rescue => e
        logger.error("#{e} (meter buzznid: #{contract[:buzznid]})")
        e.backtrace.each { |row| logger.error("  #{row}") }
      end
    end
  end

  private

  def create_contract(localpool, customer, contract, registers, tariffs)
    register_meta_option = Register::MetaOption.new(share_with_group: false, share_publicly: false)
    register = find_or_create_register(contract, registers, localpool)
    payments = contract.delete(:payments)
    contract_attributes = contract.except(:powertaker, :buzznid).merge(
      localpool:       localpool,
      register_meta:   register.meta,
      register_meta_option: register_meta_option,
      customer:        customer,
      contractor:      localpool.owner,
    )
    contract = Contract::LocalpoolPowerTaker.create!(contract_attributes)
    contract.tariffs = tariffs
    Beekeeper::Importer::Payments.new(logger).run(contract, payments)
    # TODO select proper tariffs again?
    #  if contract.end_date.nil?
    #    tariffs_running_contracts(contract, tariffs)
    #  else
    #    tariffs_ended_contracts(contract, tariffs)
    #  end
    if contract.begin_date < localpool.start_date
      localpool.start_date = contract.begin_date
      localpool.save
    end
    raise ActiveRecord::RecordInvalid.new(contract) unless contract.invariant_valid?
  end

  def tariffs_running_contracts(contract, tariffs)
    tariffs.select do |tariff|
      tariff.end_date.nil? || tariff.end_date > contract.begin_date
    end
  end

  def tariffs_ended_contracts(contract, tariffs)
    tariffs.select do |tariff|
      tariff.begin_date <= contract.end_date && (tariff.end_date.nil? || tariff.end_date >= contract.begin_date)
    end
  end

  def find_or_create_register(contract, registers, localpool)
    meter = registers.collect(&:meter).find { |m| m.legacy_buzznid == contract[:buzznid] }
    if meter
      meter.registers.first
    else
      create_fake_register(contract[:buzznid], localpool) if contract[:buzznid].present?
    end
  end

  def create_third_party_contract(localpool, contract, registers, warnings)
    if register = find_or_create_register(contract, registers, localpool)

      contract_attributes = contract.except(:powertaker, :buzznid).merge(
        localpool:     localpool,
        register_meta: register.meta
      )
      Contract::LocalpoolThirdParty.create!(contract_attributes)
    else
      warnings["contract #{contract[:contract_number]}/#{contract[:contract_number_addition]}"] = { :register => 'not found - no buzznid' }
    end
  end

  # As a temporary solution to importing the actual virtual registers (separate story), we create a fake, empty one.
  def create_fake_register(buzznid, localpool)
    logger.warn("No meter/register for #{buzznid}, creating a fake temporary one.")
    meter = Meter::Real.create!(product_serialnumber: "FAKE-FOR-IMPORT-#{counter}", legacy_buzznid: buzznid, group: localpool)
    meta = Register::Meta.new(name: "FAKE-FOR-IMPORT-M-#{counter}", label: :other, observer_enabled: false, observer_offline_monitoring: false)
    Register::Real.create!(meta: meta, meter: meter)
  end

  def counter
    $counter = $counter.to_i + 1
  end

  # Make sure we don't create the same person or organization twice.
  def find_or_create_customer(unsaved_record)
    Beekeeper::Importer::FindOrCreatePersonOrOrganization.new(logger).run(unsaved_record)
  end

end
