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
      incompleteness: loggable_incompleteness(logger.incompleteness),
      warnings:       loggable_warnings(logger.warnings)
    }
  end

  def loggable_warnings(warnings)
    warnings.map do |key, value|
      text = "#{key}: #{value}"
      ::LocalpoolLog::MessageData.new(:warn, text, "warnings").to_h
    end
  end

  def loggable_incompleteness(incompleteness)
    messages = []
    incompleteness.each do |field, data|
      text = if data.is_a?(Hash)
              data.each do |sub_field, messages|
                text = "#{field}/#{sub_field}: #{messages.join(', ')}"
                messages << ::LocalpoolLog::MessageData.new(:warn, text, "incompleteness").to_h
              end
            elsif data.is_a?(Array)
              text = "#{field}: #{data.join(', ')}"
              messages << ::LocalpoolLog::MessageData.new(:warn, text, "incompleteness").to_h
            else
              raise "Unexpected data on incompleteness"
            end
    end
    messages
  end

end
