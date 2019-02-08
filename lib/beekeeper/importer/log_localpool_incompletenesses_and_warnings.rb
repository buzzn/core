class Beekeeper::Importer::LogIncompletenessesAndWarnings

  attr_reader :logger

  def initialize(logger)
    @meters = ::Import.global('services.datasource.discovergy.meters')
    @logger = logger
    @logger.section = 'incompleteness-and-warnings'
  end

  def run(localpool_id, warnings)
    resource = Admin::LocalpoolResource.all(buzzn_operator_account).retrieve(localpool_id)

    # Debug the incompleteness
    # logger.debug "Owner is a #{resource.owner.class}."
    # logger.debug("Owner email/id: #{resource.owner.email}/#{resource.owner.id}")

    unless resource.owner.is_a?(PersonResource)
      contact = resource.owner.object.contact
      logger.debug("Contact: #{contact.email}/#{contact.id}")
    end

    logger.incompleteness = resource.incompleteness
    logger.warnings       = warnings
  end

  private

  def buzzn_operator_account
    @_account ||= Account::Base.where(email: %w(dev+ops@buzzn.net philipp@buzzn.net)).first
  end

end
