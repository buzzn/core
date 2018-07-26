class Beekeeper::Importer::Brokers

  attr_reader :logger

  def initialize(logger)
    @discovergy = ::Import.global('services.datasource.discovergy.meters')
    @logger = logger
  end

  def run(localpool, warnings)
    meters = localpool.meters.real
    meters.each do |meter|
      if easymeter?(meter.product_serialnumber)
        setup_easymeter(meter, warnings)
      else # non-easymeter
        setup_non_easymeter(meter, warnings)
      end
    end

    logged = false
    if meters.all?(&:discovergy?)
      logger.info 'All meters connected with Discovergy'
    elsif meters.all? { |m| m.other? || m.standard_profile? }
      logger.info 'All meters are Standard-Profile or not connected to Discovergy'
    else
      logged = true
      log_meters(meters, warnings)
    end

    unless logged
      has_other = false
      each_register(meters) do |register|
        has_other ||= register.meta.other?
      end
      if has_other
        log_meters(meters, warnings)
      end
    end

    warnings
  end

  private

  def setup_easymeter(meter, warnings)
    switch_manufacturer(meter, :easy_meter, warnings)
    if connected?(meter.product_serialnumber)
      meter.discovergy!
      switch_measurement_method(meter, :remote, warnings)
    else # not connected
      meter.standard_profile!
      switch_measurement_method(meter, :manual, warnings)
    end
  end

  def setup_non_easymeter(meter, warnings)
    meter.standard_profile!
    switch_manufacturer(meter, :other, warnings)
    switch_measurement_method(meter, :manual, warnings)
  end

  def each_register(meters)
    meters.each do |meter|
      meter.registers.each do |register|
        yield(register)
      end
    end
  end

  def log_meters(meters, warnings)
    each_register(meters) do |register|
      warnings["Register '#{register.meter.legacy_buzznid}' (#{register.meter.manufacturer_name} : #{register.meter.product_serialnumber} : #{register.meta.label})"] = register.meter.datasource
    end
  end

  def switch_manufacturer(meter, manufacturer, warnings)
    unless meter.send("#{manufacturer}?")
      warnings["Meter '#{meter.legacy_buzznid}' wrong manufacturer_name (#{meter.manufacturer_name})"] = manufacturer
      meter.send("#{manufacturer}!")
    end
  end

  def switch_measurement_method(meter, method, warnings)
    unless meter.send("#{method}?")
      warnings["Meter '#{meter.legacy_buzznid}' wrong edifact_measurement_method (#{meter.edifact_measurement_method})"] = method
      meter.send("#{method}!")
    end
  end

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
