class JsonLogWriter

  def initialize(loggers)
    @loggers = loggers
  end

  def write!
    all_data = @loggers.map { |logger| data_for_logger(logger) }
    File.open('log/beekeeper_import.json', 'w') { |f| f.write(all_data.to_json) }
  end

  private

  def data_for_logger(logger)
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
