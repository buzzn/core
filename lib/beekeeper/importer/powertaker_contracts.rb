class Beekeeper::Importer::PowerTakerContracts

  attr_reader :logger

  def initialize(logger)
    @logger = logger
  end

  def run(localpool, powertaker_contracts)
    powertaker_contracts.each do |contract|
      begin
        ActiveRecord::Base.transaction do
          customer = find_or_create_powertaker(contract[:powertaker])
          meter = Meter::Real.find_by(product_serialnumber: contract[:meter_serialnumber])
          register = if meter
            meter.registers.input.first
          else
            info = "vertragsnummer: #{contract[:contract_number]}/#{contract[:contract_number_addition]} (#{customer.name})"
            logger.error("Meter with serial '#{contract[:meter_serialnumber]}' not found. #{info}")
            # FIXME: temporary hack because the correct registers still need to be assigned (using the buzznid).
            meter = Meter::Real.find_or_create_by(product_serialnumber: 'FAKE-FOR-IMPORT')
            Register::Input.find_or_create_by(name: "Fake temporary register for import", share_with_group: false, meter: meter)
          end
          attrs = contract.except(:powertaker, :meter_serialnumber).merge(
            customer: customer,
            contractor: localpool.owner,
            localpool: localpool,
            register: register
          )
          ::Contract::LocalpoolPowerTaker.create!(attrs)
        end
      rescue => e
        logger.error("#{e} (meter serial: #{contract[:meter_serialnumber]})")
      end
    end
  end

  private

  # Make sure we don't create the same person twice.
  def find_or_create_powertaker(unsaved_person)
    # Unfortunately some persons can have the same email address in Beekeeper, so we need to add first and last name.
    uniqueness_attrs = unsaved_person.attributes.slice("email", "first_name", "last_name")
    person = Person.find_by(uniqueness_attrs)
    if person
      logger.debug "#{unsaved_person.name} (#{unsaved_person.email}): using existing person #{person.id}"
      person
    else
      logger.debug "#{unsaved_person.name} (#{unsaved_person.email}): creating new person instance"
      unsaved_person.save!
      unsaved_person
    end
  end
end
