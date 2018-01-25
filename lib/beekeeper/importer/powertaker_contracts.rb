class Beekeeper::Importer::PowerTakerContracts

  attr_reader :logger

  def initialize(logger)
    @logger = logger
    logger.level = Logger::INFO
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
    unsaved_record.is_a?(Person) ? find_or_create_person(unsaved_record) : find_or_create_organization(unsaved_record)
  end

  def find_or_create_person(unsaved_record)
    # Unfortunately some persons can have the same email address in Beekeeper, so we need to add first and last name.
    uniqueness_attrs = unsaved_record.attributes.slice("email", "first_name", "last_name")
    person = Person.find_by(uniqueness_attrs)
    if person
      logger.debug "#{unsaved_record.name} (#{unsaved_record.email}): using existing person #{person.id}"
      create_address(person, unsaved_record.address)
      person
    else
      logger.debug "#{unsaved_record.name} (#{unsaved_record.email} #{unsaved_record.address})): creating new person with address instance"
      unsaved_record.save!
      unsaved_record
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

  # Deduplication of the beekeeper data
  def find_or_create_organization(unsaved_record)
    logger.debug(unsaved_record.name)
    account_new_fibunr = ORGANIZATION_DATA_LOOKUPS[:account_new].find { |pattern, fibunr| unsaved_record.name =~ pattern }&.at(1)
    kontaktdaten_id    = ORGANIZATION_DATA_LOOKUPS[:kontaktdaten].find { |pattern, fibunr| unsaved_record.name =~ pattern }&.at(1)
    org_with_same_slug = Organization.find_by(slug: Buzzn::Slug.new(unsaved_record.name))

    if account_new_fibunr
      logger.debug("Taking organization from account_new")
      # get the data to use for our record
      source_record = Beekeeper::Buzzn::AccountNew.find_by(fibunr: account_new_fibunr)
      # check if we already created it
      slug = Buzzn::Slug.new(source_record.converted_attributes[:name])
      org = Organization.find_by(slug: slug)
      if org
        # if we do, return that record
        org
      else
        # if not, create it and return it
        Organization.create!(source_record.converted_attributes)
      end
    elsif kontaktdaten_id
      logger.debug("Taking organization from kontaktdaten")
      # get the data to use for our record
      source_record = Beekeeper::Minipool::Kontaktdaten.find_by(kontaktdaten_id: kontaktdaten_id)
      # check if we already created it
      slug = Buzzn::Slug.new(source_record.converted_attributes[:name])
      org = Organization.find_by(slug: slug)
      if org
        # if we do, return that record
        org
      else
        # if not, create it and return it
        Organization.create!(source_record.converted_attributes)
      end
    elsif org_with_same_slug
      logger.debug("Using existing org with same slug")
      org_with_same_slug
    else # lookup is configured for this record, import data as is, no deduplication
      logger.debug("Creating new organization")
      unsaved_record.save!
      unsaved_record
    end
  end

  # Only placed at the end because the regexp patterns as hash keys mess up my syntax highlighting ...

  ORGANIZATION_DATA_LOOKUPS = {

    # key: pattern for kontaktdaten.firma
    # value: account_new.fibunr of the record that should be used for data
    account_new: {
      /wagnis/i           => 70069,
      /Cohaus/            => 80792,
      /IGEWO/             => 80583,
      /Hans Fischer GmbH/ => 80678,
      /BEG Remstal/       => 80502,
    },

    # key: pattern for kontaktdaten.firma
    # value: kontaktdaten.kontaktdaten_id of the record that should be used for data
    kontaktdaten: {
      /Parkgelände GmbH/                         => 624,
      /Diakonie Stetten/                         => 790,
      /Gemeinde Hallbergmoos/                    => 777,
      /IFAGE Grundstücksverwaltungs GmbH/        => 442,
      /Ritter Baukontor GmbH/                    => 1097,
      /Umbreit, Olé Madrid/                      => 46,
      /VR Dachau Immobilien GmbH/                => 894,
      /WEG Hausverwaltung Alte Rommelshauser St/ => 1070,
      /WHG Wohnungsbau/                          => 430,
      /Wogeno München eG/                        => 998,
    }
  }

end
