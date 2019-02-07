ActiveRecord::Base.send(:include, Schemas::Support::ValidateInvariant)

class Beekeeper::Import

  class << self

    def run!
      new.run
    end

  end

  def run
    max = 10
    loggers = Beekeeper::Minipool::MinipoolObjekte.to_import[0, max].map do |record|
      logger = LocalpoolLog.new(record)
      import_localpool(record, logger)
      logger
    end
    # Beekeeper::Importer::LogImportSummary.new(logger).run
    JsonLogWriter.new(loggers).write!
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
      Beekeeper::Importer::GenerateBillings.new(logger, beekeeper_account).run(localpool)

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

end
