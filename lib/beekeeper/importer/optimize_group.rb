class Beekeeper::Importer::OptimizeGroup

  attr_reader :logger

  OMIT_VIRTUAL_IDS      = (0..127).to_a + [9999997]
  OPTIMIZED_GROUPS_YAML = 'config/optimized_groups.yaml'

  def initialize(logger)
    @meters    = ::Import.global('services.datasource.discovergy.meters')
    @optimized = ::Import.global('services.datasource.discovergy.optimized_group')
    @logger    = logger
  end

  def run(localpool, warnings)
    if optimized_groups.key?(localpool.slug)
      setup_optimized_groups(localpool, optimized_groups[localpool.slug])
      return
    end

    all_virtual_discovergy_meters = @optimized.local(localpool).collect do |m|
      optimized_map[m.product_serialnumber]
    end

    virtual_discovergy_meters = allowed_virtual_discovergy_meters(all_virtual_discovergy_meters)
    if virtual_discovergy_meters
      process_virtual_list(virtual_discovergy_meters, localpool, warnings)
    else
      create_optimized_group(localpool, warnings)
    end

    persist_optimized_groups
  end

  private

  def allowed_virtual_discovergy_meters(all_meters_list)
    all_meters_list
      .compact
      .collect { |meters| allowed_discovergy_ids(meters) }
      .select { |meters| !meters.empty? && !meters.registers.first.other? }
      .reduce(&:|)
  end

  def allowed_discovergy_ids(discovergy_virtual_meters)
    discovergy_virtual_meters.reject do |i|
      OMIT_VIRTUAL_IDS.include?(i.serialNumber.to_i)
    end
  end

  def setup_optimized_groups(localpool, serial)
    if serial
      Broker::Discovergy.create(meter: Meter::Discovergy.create(product_serialnumber: serial, group: localpool))
    end
  end

  def process_virtual_list(virtual_list, localpool, warnings)
    case virtual_list.size
    when 0
      warnings['discovergy'] = 'not all easymeters are in optimized group'
    when 1
      serial = virtual_list.first.serialNumber
      Broker::Discovergy.create(meter: Meter::Discovergy.create(product_serialnumber: serial, group: localpool))
      logger.info "Found optimized group #{serial}"
      optimized_groups[localpool.slug] = serial
      unless @optimized.verify(localpool)
        warnings['discovergy'] = 'list of local and remote meters mismatch.'
      end
    else
      warnings['discovergy'] = "found more than one virtual meter on Discovergy. can not optimized group: #{virtual_list.collect{|v| v.serialNumber}}"
    end
  end

  def create_optimized_group(localpool, warnings)
    if !@optimized.local(localpool).empty? && !localpool.start_date.future? && discovergy_only?(localpool, warnings) && complete?(localpool)
      warnings['discovergy.optimized_group'] = "create optimized group for #{localpool.slug}"
      binding.pry
      #meter = @optimized.create(localpool)
      #optimized_groups[localpool.slug] = meter.product_serialnumber
    else
      optimized_groups[localpool.slug] = nil
    end
  end

  def discovergy_only?(localpool, warnings)
    discovergy_meters = Set.new(@optimized.local(localpool))
    localpool_meters = Set.new(localpool.registers.grid_production_consumption.collect {|r| r.meter})
    all_registers = discovergy_meters.collect { |m| m.registers }.flatten

    discovergy_meters == localpool_meters
  end

  def complete?(localpool)
    registers = @optimized.local(localpool).collect { |m| m.registers }.flatten
    registers.one? { |r| r.grid_consumption? } &&
      registers.one? { |r| r.grid_feeding? } &&
      registers.one? { |r| r.label.production? } &&
      registers.one? { |r| r.label.consumption? }
  end

  def optimized_groups
    @optimized_groups ||= YAML.load(File.read(OPTIMIZED_GROUPS_YAML))
  rescue
    logger.info('Unable to find optimized_groups file; it will be recreated.')
    @optimized_groups = {}
  end

  def persist_optimized_groups
    File.write(OPTIMIZED_GROUPS_YAML, Hash[@optimized_groups.sort].to_yaml)
  end

  def optimized_map
    @meter_to_virtual_map ||= @meters.meter_to_virtual_map
  end

end
