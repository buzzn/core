class Beekeeper::Importer::RegistersAndMeters

  attr_reader :logger

  def initialize(logger)
    @logger = logger
    @logger.section = 'create-registers-and-meters'
  end

  def run(localpool, registers)
    registers.collect do |register|
      register.meter.group = localpool
      unless register.save
        logger.error("Failed to save register #{register.inspect}", extra_data: register.errors)
      end
      register
    end
  end

end
