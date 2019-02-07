ActiveRecord::Base.send(:include, Schemas::Support::ValidateInvariant)

class Beekeeper::Import

  class << self

    def run!
      new.run
    end

  end

  def run
    max = 100
    loggers = Beekeeper::Minipool::MinipoolObjekte.to_import[0, max].map do |record|
      logger = LocalpoolLog.new(record)
      Beekeeper::Minipool::BaseRecord.logger = Beekeeper::Buzzn::BaseRecord.logger = logger
      import_localpool(record, logger)
      logger
    end
    # Beekeeper::Importer::LogImportSummary.new(logger).run
    write_json_log(loggers)
  end

  private

  def import_localpool(record, logger)
    beekeeper_account = Account::Base.where(:email => 'dev+beekeeper@buzzn.net').first
    if beekeeper_account.nil?
      raise 'please create a beekeeper account first'
    end

    warnings = record.warnings || {}
    Group::Localpool.transaction do
      # need to create localpool with broken invariants
      localpool = Beekeeper::Importer::CreateLocalpool.new(logger).run(record.converted_attributes)
      Beekeeper::Importer::Roles.new(logger).run(localpool)
      registers = Beekeeper::Importer::RegistersAndMeters.new(logger).run(localpool, record.converted_attributes[:registers])
      tariffs = Beekeeper::Importer::Tariffs.new(logger).run(localpool, record.converted_attributes[:tariffs])
      Beekeeper::Importer::GroupContracts.new(logger).run(localpool, record.converted_attributes)
      Beekeeper::Importer::LocalpoolContracts.new(logger).run(localpool, record.converted_attributes[:powertaker_contracts], record.converted_attributes[:third_party_contracts], registers, tariffs, warnings)
      Beekeeper::Importer::SetLocalpoolGapContractCustomer.new(logger).run(localpool)
      Beekeeper::Importer::AdjustLocalpoolContractsAndReadings.new(logger).run(localpool)
      # TODO: exception handling into GenerateBillings. add error source & data
      begin
        Beekeeper::Importer::GenerateBillings.new(logger, beekeeper_account).run(localpool)
      rescue Buzzn::ValidationError => e
        logger.error(e.errors)
      end

      # now we can fail and rollback on broken invariants
      raise ActiveRecord::RecordInvalid.new(localpool) unless localpool.invariant_valid?
      localpool.save!

      unless Import.global?('config.skip_brokers')
        Beekeeper::Importer::Brokers.new(logger).run(localpool, warnings)
        Beekeeper::Importer::OptimizeGroup.new(logger).run(localpool, warnings)
      end
      Beekeeper::Importer::LogIncompletenessesAndWarnings.new(logger).run(localpool.id, warnings)
    end
  end

  private

  # How to use the log levels:
  # DEBUG          debugging and technical details not relevant/comprehensible by PhO
  # INFO (default) PhO should see and review this before the final import
  # WARN           should be fixed in the final import, but we can live with it for now
  # ERROR          something went wrong (like exceptions), should be investigated immediately
  def write_json_log(loggers)
    # TODO: put this somewhere. and structure them like messages.
    # if incompleteness.present?
    #   incompleteness.each do |field, messages|
    #     logger.warn("#{field}: #{messages.inspect} (incompleteness)")
    #   end
    # end
    #     unless warnings.empty?
    #   warnings.each do |field, message|
    #     if message.is_a?(Hash)
    #       message.each do |subfield, submessage|
    #         logger.warn("#{field}:")
    #         logger.warn("- #{subfield}: #{submessage}")
    #       end
    #     else
    #       logger.warn("#{field}: #{message}")
    #     end
    #   end
    # end

    json = loggers.map do |logger|
      {
        localpool: {
          name:            logger.localpool.minipool_name,
          start_date:      logger.localpool.minipool_start ? Time.parse(logger.localpool.minipool_start) : nil,
          contract_number: logger.localpool.vertragsnummer
        },
        messages:  logger.messages
      }
    end.to_json
    File.open('log/beekeeper_import.log', 'w') { |f| f.write(json) }
  end

end
