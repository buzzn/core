class Beekeeper::Importer::Brokers

  attr_reader :logger

  def initialize(logger)
    @meters = ::Import.global('services.datasource.discovergy.meters')
    @logger = logger
  end

  def run(localpool, warnings)
    without_broker = localpool.meters.real.select do |meter|
      if meter.easy_meter?
        if meter_on_discovergy?(meter.product_serialnumber)
          Broker::Discovergy.create!(meter: meter)
          false
        else
          # these are the ones we have, but are not on Discovergy.
          true
        end
      else
        false # non-easymeters are not smart and thus not connectable to Discovergy
      end
    end
    without_broker.each do |meter|
      meter.registers.each do |register|
        warnings["register '#{register.name}'"] = 'is not on Discovergy'
      end
    end
    warnings
    #without_meter = map.select { |serial, _| !Meter::Real.where(product_serialnumber: serial).exists? }
  end

  private

  def meter_on_discovergy?(serialnumber)
    meter_map.key?(serialnumber)
  end

  def meter_map
    @meter_map ||= @meters.real
  end
end
