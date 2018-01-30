class Beekeeper::Importer::PowerTakerContracts

  attr_reader :logger

  def initialize(logger)
    @logger = logger
    logger.level = Import.global('config.log_level')
  end

  def run(localpool, powertaker_contracts, registers)
    powertaker_contracts.each do |contract|
      begin
        ActiveRecord::Base.transaction do
          customer = find_or_create_customer(contract[:powertaker])
          create_contract(localpool, customer, contract, registers)
        end
      rescue => e
        logger.error("#{e} (meter buzznid: #{contract[:buzznid]})")
      end
    end
  end

  private

  def create_contract(localpool, customer, contract, registers)
    meter    = registers.map(&:meter).find { |m| m.legacy_buzznid == contract[:buzznid] }
    register = if meter
      meter.registers.input.first
    else
      create_fake_virtual_register(contract[:buzznid])
    end
    contract_attributes = contract.except(:powertaker, :buzznid).merge(
      localpool:  localpool,
      register:   register,
      customer:   customer,
      contractor: localpool.owner
    )
    Contract::LocalpoolPowerTaker.create!(contract_attributes)
  end

  # As a temporary solution to importing the actual virtual registers (separate story), we create a fake, empty one.
  def create_fake_virtual_register(buzznid)
    logger.error("No meter/register for #{buzznid}, creating a fake temporary one.")
    meter = Meter::Real.create!(product_serialnumber: 'FAKE-FOR-IMPORT', legacy_buzznid: buzznid)
    Register::Input.create!(name: "FAKE-FOR-IMPORT", share_with_group: false, meter: meter)
  end

  # Make sure we don't create the same person or organization twice.
  def find_or_create_customer(unsaved_record)
    Beekeeper::Importer::FindOrCreatePersonOrOrganization.new(logger).run(unsaved_record)
  end
end
