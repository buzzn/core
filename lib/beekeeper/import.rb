ActiveRecord::Base.send(:include, Schemas::Support::ValidateInvariant)

class Beekeeper::Import

  class << self
    def run!
      new.run
    end
  end

  def run
    #ActiveRecord::Base.logger = Logger.new(STDOUT)
    logger.info("-" * 80)
    logger.info("Starting import")
    logger.info("-" * 80)
    Beekeeper::Minipool::MinipoolObjekte.to_import.each { |record| import_localpool(record) }
    Beekeeper::Importer::LogImportSummary.new(logger).run
  end

  private

  def import_localpool(record)
    logger.info("\n")
    logger.info("Localpool #{record.converted_attributes[:name]} (start: #{record.converted_attributes[:start_date]})")
    logger.info("-" * 80)

    Group::Localpool.transaction do
      # need to create localpool with broken invariants
      localpool = Group::Localpool.create(record.converted_attributes.except(:registers, :powertaker_contracts))

      Beekeeper::Importer::Roles.new(logger).run(localpool)
      Beekeeper::Importer::RegistersAndMeters.new(logger).run(localpool, record.converted_attributes[:registers])
      Beekeeper::Importer::PowerTakerContracts.new(logger).run(localpool, record.converted_attributes[:powertaker_contracts])

      # now we can fail and rollback on broken invariants
      raise ActiveRecord::RecordInvalid.new(localpool) unless localpool.invariant_valid?
      localpool.save!

      warnings = record.warnings || {}
      Beekeeper::Importer::Brokers.new(logger).run(localpool, warnings)
      Beekeeper::Importer::OptimizeGroups.new(logger).run(localpool, warnings)
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
