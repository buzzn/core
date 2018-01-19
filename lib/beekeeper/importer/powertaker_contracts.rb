class Beekeeper::Importer::PowerTakerContracts

  attr_reader :logger

  def initialize(logger)
    @logger = logger
  end

  def run(localpool, powertaker_contracts, registers)
    powertaker_contracts.each do |contract|
      begin
        ActiveRecord::Base.transaction do
          customer = find_or_create_powertaker(contract[:powertaker])
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

  # Make sure we don't create the same person twice.
  def find_or_create_powertaker(unsaved_person)
    # Unfortunately some persons can have the same email address in Beekeeper, so we need to add first and last name.
    uniqueness_attrs = unsaved_person.attributes.slice("email", "first_name", "last_name")
    person = Person.find_by(uniqueness_attrs)
    if person
      logger.debug "#{unsaved_person.name} (#{unsaved_person.email}): using existing person #{person.id}"
      create_address(person, unsaved_person.address)
      person
    else
      logger.debug "#{unsaved_person.name} (#{unsaved_person.email} #{unsaved_person.address})): creating new person with address instance"
      unsaved_person.save!
      unsaved_person
    end
  end

  def create_address(person, address)
    return if person.address
    address.save!
    person.update(address: address)
    logger.debug "#{address}): creating new address for existing person #{person.id}"
  end

  # As a temporary solution to importing the actual virtual registers (separate story), we create a fake, empty one.
  def create_fake_virtual_register(buzznid)
    logger.error("No meter/register for #{buzznid}, creating a fake temporary one.")
    meter = Meter::Real.create!(product_serialnumber: 'FAKE-FOR-IMPORT', legacy_buzznid: buzznid)
    Register::Input.create!(name: "FAKE-FOR-IMPORT", share_with_group: false, meter: meter)
  end
end
