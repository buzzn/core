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
      find_or_create_person(unsaved_record)
    elsif unsaved_record.is_a?(Organization)
      find_or_create_organization(unsaved_record)
    else
      raise "Can't handle records of type #{unsaved_record.class}"
    end
  end

  private

  def find_or_create_person(unsaved_record)
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
      ap "unsaved_record.contact"
      ap unsaved_record.contact
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
