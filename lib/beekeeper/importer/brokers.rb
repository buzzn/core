class Beekeeper::Importer::Brokers

  attr_reader :logger

  def initialize(logger)
    @discovergy = ::Import.global('services.datasource.discovergy.meters')
    @logger = logger
  end

  def run(localpool, warnings)
    meters = localpool.meters.real
    meters.each do |meter|
      meter.standard_profile!
      meter.manual!
      if easymeter?(meter.product_serialnumber)
        meter.easy_meter!
        if connected?(meter.product_serialnumber)
          meter.discovergy!
          meter.remote!
        end
      #else
      #  meter.other!
      end
      meter.easy_meter? && !meter.discovergy?
    end

    if meters.all? { |m| m.discovergy? }
      logger.info 'All meters connected with Discovergy'
    elsif meters.all? { |m| m.other? || m.standard_profile? }
      logger.info 'All meters are Standard-Profile'
    else
      meters.each do |meter|
        meter.registers.each do |register|
          warnings["register '#{register.meter.legacy_buzznid}' (#{register.meter.manufacturer_name} : #{register.meter.product_serialnumber} : #{register.label})"] = register.meter.datasource
        end
      end
    end
    warnings
  end

  private

  def easymeter?(serialnumber)
    discovergy_easymeters.key?(serialnumber)
  end

  def connected?(serialnumber)
    @discovergy.connected?(serialnumber)
  end

  def discovergy_easymeters
    $discovergy_easymeters ||= @discovergy.easymeters
  end

end
