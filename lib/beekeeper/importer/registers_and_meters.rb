class Beekeeper::Importer::RegistersAndMeters

  attr_reader :logger

  def initialize(logger)
    @logger = logger
  end

  def run(localpool, registers)
    registers.map do |register|
      register.meter.group = localpool
      unless register.save
        logger.error("Failed to save register #{register.inspect}")
        logger.error("Errors: #{register.errors.inspect}")
      end
      register
    end
  end
end
