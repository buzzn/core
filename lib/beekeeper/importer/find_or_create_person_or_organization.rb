# This class is responsible for merging the many duplicated persons and organizations in beekeeper
# into one person or organization record each in our database.
class Beekeeper::Importer::FindOrCreatePersonOrOrganization

  attr_reader :logger

  def initialize(logger)
    @logger = logger
    logger.level = Import.global('config.log_level')
  end

  def run(unsaved_record)
    if unsaved_record.is_a?(Person)
      get_unique_person(unsaved_record)
    elsif unsaved_record.is_a?(Organization)
      get_unique_organization(unsaved_record)
    else
      raise "Can't handle records of type #{unsaved_record.class}"
    end
  end

  private

  def get_unique_person(unsaved_record)
    # Unfortunately different persons can have the same email address in Beekeeper, so we need to add first and last name.
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

  # Deduplication of the beekeeper data
  def get_unique_organization(unsaved_record)
    logger.debug("xxx #{unsaved_record.name}")

    if (existing_org = find_organization(unsaved_record.name))
      logger.debug("xxx Using existing org: #{existing_org.name}")
      existing_org

    elsif (fibunr = find_account_new_fibunr(unsaved_record.name))
      logger.debug("xxx Taking organization from account_new")
      # get the data to use for our record
      source_record = Beekeeper::Buzzn::AccountNew.find_by(fibunr: fibunr)
      find_or_create_organization(source_record.converted_attributes)

    elsif (kontaktdaten_id = find_kontaktdaten_id(unsaved_record.name))
      logger.debug("xxx Taking organization from kontaktdaten")
      # get the data to use for our record
      source_record = Beekeeper::Minipool::Kontaktdaten.find_by(kontaktdaten_id: kontaktdaten_id)
      find_or_create_organization(source_record.converted_attributes)

    else # no lookup is configured, create a new organization record
      logger.debug("xxx Creating new organization")
      unsaved_record.save!
      unsaved_record
    end
  end

  def find_account_new_fibunr(organization_name)
    ORGANIZATION_DATA_LOOKUPS[:account_new].find { |pattern, fibunr| organization_name =~ pattern }&.at(1)
  end

  def find_kontaktdaten_id(organization_name)
    ORGANIZATION_DATA_LOOKUPS[:kontaktdaten].find { |pattern, fibunr| organization_name =~ pattern }&.at(1)
  end

  def create_address(person, address)
    return if person.address
    address.save!
    person.update(address: address)
    logger.debug "#{address}): creating new address for existing person #{person.id}"
  end

  def find_or_create_organization(attributes)
    org = find_organization(attributes[:name])
    org ? org : Organization.create!(attributes)
  end

  def find_organization(name)
    Organization.find_by(slug: Buzzn::Slug.new(name))
  end

  # Only placed at the end because the regexp patterns as hash keys mess up my syntax highlighting ...

  ORGANIZATION_DATA_LOOKUPS = {

    # key: pattern for kontaktdaten.firma
    # value: account_new.fibunr of the record that should be used for data
    account_new: {
      /wagnis/i            => 70069,
      /Cohaus/i            => 80792,
      /IGEWO/i             => 80583,
      /Hans Fischer GmbH/i => 80678,
      /BEG Remstal/i       => 80502,
    },

    # key: pattern for kontaktdaten.firma
    # value: kontaktdaten.kontaktdaten_id of the record that should be used for data
    kontaktdaten: {
      /Parkgelände GmbH/i                         => 624,
      /Diakonie Stetten/i                         => 790,
      /Gemeinde Hallbergmoos/i                    => 777,
      /IFAGE Grundstücksverwaltungs GmbH/i        => 442,
      /Ritter Baukontor GmbH/i                    => 1097,
      /Umbreit, Olé Madrid/i                      => 46,
      /VR Dachau Immobilien GmbH/i                => 894,
      /WEG Hausverwaltung Alte Rommelshauser St/i => 1070,
      /WHG Wohnungsbau/i                          => 430,
      /Wogeno München eG/i                        => 998,
    }
  }
end
