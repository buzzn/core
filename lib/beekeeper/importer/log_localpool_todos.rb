class Beekeeper::Importer::LogLocalpoolTodos

  attr_reader :logger

  def initialize(logger)
    @meters = ::Import.global('services.datasource.discovergy.meters')
    @logger = logger
  end

  def run(localpool_id, warnings)
    resource = Admin::LocalpoolResource.all(buzzn_operator_account).retrieve(localpool_id)
    incompleteness = if resource.object.start_date.future?
      logger.info("Skipping incompleteness checks, localpool hasn't started yet")
      []
    else
      resource.incompleteness
    end

    unless incompleteness.present? || warnings.present?
      logger.info("Nothing to do!")
      return
    end

    if incompleteness.present?
      incompleteness.each do |field, messages|
        logger.info("#{field}: #{messages.join(', ')} (incompleteness)")
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
    @_account ||= Account::Base.find_by_email('dev+ops@buzzn.net')
  end
end
