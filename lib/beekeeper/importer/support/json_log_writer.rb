class JsonLogWriter

  def initialize(loggers)
    @loggers = loggers
  end

  def write!
    loggable_array = @loggers.map { |logger| loggable_hash(logger) }
    File.open('log/beekeeper_import.json', 'w') { |f| f.write(loggable_array.to_json) }
  end

  private

  def loggable_hash(logger)
    {
      localpool: {
          name:            logger.localpool.minipool_name,
          start_date:      logger.localpool.minipool_start ? Time.parse(logger.localpool.minipool_start) : nil,
          contract_number: logger.localpool.vertragsnummer
      },
      messages:       logger.messages,
      incompleteness: logger.incompleteness,
      warnings:       logger.warnings
    }
  end
end
