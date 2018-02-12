class Beekeeper::Importer::LogLocalpoolTodos

  attr_reader :logger

  def initialize(logger)
    @meters = ::Import.global('services.datasource.discovergy.meters')
    @logger = logger
    @logger.level = Import.global('config.log_level')
  end

  def run(localpool_id, warnings)
    resource = Admin::LocalpoolResource.all(buzzn_operator_account).retrieve(localpool_id)

    # Debug the incompleteness
    logger.debug "owner is a #{resource.owner.class}."
    logger.debug("Owner email/id: #{resource.owner.email}/#{resource.owner.id}")

    unless resource.owner.is_a?(PersonResource)
      contact = resource.owner.object.contact
      logger.debug("contact: #{contact.email}/#{contact.id}")
    end

    incompleteness = if resource.object.start_date.future?
                       logger.info("Skipping incompleteness checks, localpool hasn't started yet")
                       []
    else
      resource.incompleteness
    end

    unless incompleteness.present? || warnings.present?
      logger.info('Nothing to do!')
      return
    end

    if incompleteness.present?
      incompleteness.each do |field, messages|
        logger.info("#{field}: #{messages.inspect} (incompleteness)")
      end
    end

    unless warnings.empty?
      warnings.each do |field, message|
        if message.is_a?(Hash)
          message.each do |subfield, submessage|
            logger.info("#{field}:")
            logger.info("- #{subfield}: #{submessage} (warning)")
          end
        else
          logger.info("#{field}: #{message} (warning)")
        end
      end
    end
  end

  private

  def buzzn_operator_account
    @_account ||= Account::Base.where(email: %w(dev+ops@buzzn.net philipp@buzzn.net)).first
  end

end
