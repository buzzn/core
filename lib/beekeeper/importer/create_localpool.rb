class Beekeeper::Importer::CreateLocalpool

  attr_reader :logger

  def initialize(logger)
    @logger = logger
    logger.level = Import.global('config.log_level')
  end

  def run(attributes)
    attrs = attributes
      .except(:registers, :powertaker_contracts, :third_party_contracts, :owner, :tariffs)
      .merge(owner: find_or_create_owner(attributes[:owner]))
    Group::Localpool.create(attrs)
  end

  # Deduplicate the group owners (there's at least one, Traudl Brumbauer)
  def find_or_create_owner(unsaved_record)
    Beekeeper::Importer::FindOrCreatePersonOrOrganization.new(logger).run(unsaved_record)
  end

end
