class Beekeeper::Importer::OptimizeGroup

  attr_reader :logger

  OMIT_VIRTUAL_IDS      = (0..105).to_a + [107, 121, 9999997]
  OPTIMIZED_GROUPS_YAML = 'config/optimized_groups.yaml'

  def initialize(logger)
    @meters    = ::Import.global('services.datasource.discovergy.meters')
    @optimized = ::Import.global('services.datasource.discovergy.optimized_group')
    @logger    = logger
  end

  def run(localpool, warnings)
    if optimized_groups.key?(localpool.slug)
      setup_optimized_groups(localpool, optimized_groups[localpool.slug])
      return warnings
    end
    list = @optimized.local(localpool).collect do |m|
      optimized_map[m.product_serialnumber]
    end

    virtual_list = nil
    list.each do |item|
      corrected = item.select { |i| !OMIT_VIRTUAL_IDS.include?(i.serialNumber.to_i) }.uniq if item
      virtual_list = virtual_list ? (virtual_list | corrected) : corrected if corrected && !corrected.empty?
    end

    if virtual_list
      process_virtual_list(virtual_list, localpool, warnings)
    else
      add_optimized_group(localpool, warnings)
    end
    persist_optimized_groups
  end

  private

  def setup_optimized_groups(localpool, serial)
    if serial
      Broker::Discovergy.create(meter: Meter::Discovergy.create(product_serialnumber: serial, group: localpool))
    end
  end

  def process_virtual_list(virtual_list, localpool, warnings)
    case virtual_list.size
    when 0
      warnings["discovergy"] = 'not all easymeters are in optimized group'
    when 1
      serial = virtual_list.first.serialNumber
      if serial.to_i >= 106
        Broker::Discovergy.create(meter: Meter::Discovergy.create(product_serialnumber: serial, group: localpool))
        puts "found optimized group #{serial}"
        optimized_groups[localpool.slug] = serial
        unless @optimized.verify(localpool)
          logger.error("BUG: list of local and remote meters doesn't match.")
        end
      else
        logger.error("BUG: serial expected to be >= 106, but was #{serial}.")
      end
    else
      warnings["discovergy"] = "found more than one virtual meter on Discovergy. can not optimized group: #{virtual_list.collect{|v| v.serialNumber}}"
    end
  end

  def add_optimized_group(localpool, warnings)
    if !@optimized.local(localpool).empty? && !localpool.start_date.future? && standard?(localpool, warnings)
      puts 'create optimized group'
      # meter = @optimized.create(localpool)
      # optimized_groups[localpool.slug] = meter.product_serialnumber
    else
      optimized_groups[localpool.slug] = nil
    end
  end

  def standard?(localpool, warnings)
    production_meters = @optimized.local(localpool).select do |m|
      m.registers.detect {|r| r.label.production? }
    end
    if production_meters.empty?
      warnings["discovergy"] = "there are consumption discovergy meters but no production discovergy"
      false
    else
      # one grid_feeding and one grid_consumption in one meter
      localpool.meters.count == @optimized.local(localpool).count + 1
    end
  end

  def optimized_groups
    @optimized_groups ||= YAML.load(File.read(OPTIMIZED_GROUPS_YAML))
  rescue
    logger.info("Unable to find optimized_groups file; it will be recreated.")
    @optimized_groups = {}
  end

  def persist_optimized_groups
    File.write(OPTIMIZED_GROUPS_YAML, Hash[@optimized_groups.sort].to_yaml)
  end

  def optimized_map
    @optimized_map ||= @meters.virtual_list
  end
end
