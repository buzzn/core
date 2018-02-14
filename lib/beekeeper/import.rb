ActiveRecord::Base.send(:include, Schemas::Support::ValidateInvariant)

class Beekeeper::Import

  class << self

    def run!
      new.run
    end

  end

  def run
    #ActiveRecord::Base.logger = Logger.new(STDOUT)
    logger.info('-' * 80)
    logger.info('Starting import')
    logger.info('-' * 80)
    Beekeeper::Minipool::MinipoolObjekte.to_import.each { |record| import_localpool(record) }
    Beekeeper::Importer::LogImportSummary.new(logger).run
  end

  private

  def import_localpool(record)
    logger.info("\n")
    logger.info("Localpool #{record.converted_attributes[:name]} (start: #{record.converted_attributes[:start_date]})")
    logger.info('-' * 80)

    warnings = record.warnings || {}
    Group::Localpool.transaction do
      # need to create localpool with broken invariants
      localpool = Beekeeper::Importer::CreateLocalpool.new(logger).run(record.converted_attributes)
      Beekeeper::Importer::Roles.new(logger).run(localpool)
      registers = Beekeeper::Importer::RegistersAndMeters.new(logger).run(localpool, record.converted_attributes[:registers])
      tariffs = Beekeeper::Importer::Tariffs.new(logger).run(localpool, record.converted_attributes[:tariffs])
      Beekeeper::Importer::LocalpoolContracts.new(logger).run(localpool, record.converted_attributes[:powertaker_contracts], record.converted_attributes[:third_party_contracts], registers, tariffs, warnings)
      Beekeeper::Importer::SetLocalpoolGapContractCustomer.new(logger).run(localpool)
      Beekeeper::Importer::AdjustLocalpoolContractsAndReadings.new(logger).run(localpool)

      # now we can fail and rollback on broken invariants
      raise ActiveRecord::RecordInvalid.new(localpool) unless localpool.invariant_valid?
      localpool.save!

      unless Import.global?('config.skip_brokers')
        Beekeeper::Importer::Brokers.new(logger).run(localpool, warnings)
        Beekeeper::Importer::OptimizeGroup.new(logger).run(localpool, warnings)
      end
      Beekeeper::Importer::LogLocalpoolTodos.new(logger).run(localpool.id, warnings)
    end
  end

  private

  def logger
    @logger ||= begin
      l = Logger.new(STDOUT)
      l.formatter = proc do |_severity, _datetime, _progname, msg|
        "#{msg}\n"
      end
      l
    end
  end

end
