# coding: utf-8

class Beekeeper::Importer::ReadingsRegistersMeters

  attr_reader :logger

  KNOWN_SUBSTITUTE_REGISTERS = ['90043/1', '90005/5', '90051/9', '90052/12']

  def initialize(logger)
    @logger = logger
    @logger.section = 'readings-registers-meters'
  end

  # TODO: clarify why the "Canary Test Group" doesn't import properly
  # IMPROVEMENT: Since beekeeper stores the serial number (zählernummer) of a register with every reading,
  # we could store that with the old register on COM1/COM2.
  def run(localpool, record)
    puts "#{localpool.name} has #{record.msb_zählwerk_daten.size} zaehlwerke"
    max_sequence_number = record.msb_zählwerk_daten.map(&:converted_attributes).map{|x| x[:meter_attributes][:sequence_number] }.max
    meters_on_date = {}
    for_each_zaehlwerk(record) do |zaehlwerk, sorted_readings|
      first_hash = sorted_readings.empty? ? 'first' : sorted_readings.first.date.iso8601
      meter = meters_on_date["#{zaehlwerk.buzznid}-#{first_hash}"]
      register = create_register(zaehlwerk, localpool, max_sequence_number, nil, meter)
      meters_on_date["#{zaehlwerk.buzznid}-#{first_hash}"] = register.meter
      puts "* Zählwerk: #{zaehlwerk.buzznid}"
      puts '-' * 50
      sorted_readings.each do |reading|
        if reading.reason == 'device_change_2'
          @builder.clear_registry
          meter = meters_on_date["#{zaehlwerk.buzznid}-#{reading.date.iso8601}"]
          register = create_register(zaehlwerk, localpool, max_sequence_number, register.meta, meter)
          meters_on_date["#{zaehlwerk.buzznid}-#{reading.date.iso8601}"] = register.meter
        end
        puts "#{reading.date.iso8601} #{reading.reason_code.rjust(5, ' ')} #{reading.value.to_s.rjust(10, ' ')} register: ##{register.id} meta: ##{register.meta.id}"
        register.readings << reading
      end
      puts '-' * 50
      puts "Created #{register.meta.registers.size} register(s). The current one is: ##{register.meta.register.id}"
      puts
      register # return registers because they are needed to create the contracts later.
    end
  end

  private

  def for_each_zaehlwerk(record)
    record.msb_zählwerk_daten.map do |zaehlwerk|
      yield [
        zaehlwerk,
        zaehlwerk.converted_attributes[:readings].sort_by { |r| "#{r.date.iso8601}-#{r.reason_code}" }
      ] # 468454000
    end
  end

  def create_register(zaehlwerk, localpool, max_sequence_number, register_meta = nil, meter = nil)
    @builder ||= RegisterBuilder.new(logger, localpool, max_sequence_number)
    register = @builder.build_register(zaehlwerk, register_meta, meter)
    register.save!
    register
  end

  class RegisterBuilder

    attr_reader :logger
    attr_reader :localpool

    def initialize(logger, localpool, max_sequence_number)
      @logger = logger
      @localpool = localpool
      @max_sequence_number = max_sequence_number
    end

    def clear_registry
      @meter_registry = {}
    end

    def build_register(zaehlwerk, register_meta = nil, meter = nil)
      if zaehlwerk.virtual?
        if KNOWN_SUBSTITUTE_REGISTERS.include?(zaehlwerk.buzznid)
          build_substitute_register(zaehlwerk, register_meta)
        else
          logger.warn("We think beekeper's #{zaehlwerk.buzznid} is a virtual meter,
                       but not a substitute one. We still don't know what to do with these.
                       For now we create a 'fake' temporary meter, so the contracts attached
                       to it can already be imported as well.", extra_data: zaehlwerk)
          build_fake_register(zaehlwerk, register_meta)
        end
      else
        build_real_register(zaehlwerk, register_meta, meter)
      end
    end

    private

    def build_substitute_register(zaehlwerk, register_meta = nil)
      attrs = zaehlwerk.converted_attributes.slice(:label, :name, :meter_attributes)
      attrs[:type] = 'Register::Substitute'
      attrs[:meter] = build_virtual_meter(attrs[:meter_attributes].slice(:sequence_number, :buzznid))
      attrs[:meta] = register_meta if register_meta
      build_any_register(attrs, zaehlwerk)
    end

    # IMPROVEMENT: could be changed to also use build_any_register
    def build_fake_register(zaehlwerk, register_meta = nil)
      fake_meter_name = "VIRTUAL-#{fake_register_counter}"
      meter = Meter::Real.create!(product_serialnumber: fake_meter_name, legacy_buzznid: zaehlwerk.buzznid, group: @localpool)
      meta = register_meta || Register::Meta.new(name: fake_meter_name.gsub('IMPORT-', 'IMPORT-M-'), label: :other, observer_enabled: false, observer_offline_monitoring: false)
      Register::Real.create!(meta: meta, meter: meter)
    end

    def build_real_register(zaehlwerk, register_meta = nil, meter = nil)
      attrs = zaehlwerk.converted_attributes.except(:readings) # assign these later!
      attrs[:meter] = meter || build_real_meter(attrs[:meter_attributes], zaehlwerk)
      attrs[:meta] = register_meta if register_meta
      build_any_register(attrs, zaehlwerk)
    end

    def fake_register_counter
      $counter = $counter.to_i + 1
    end

    def build_any_register(attrs, zaehlwerk)
      log_warnings(attrs, zaehlwerk)
      register_class = attrs[:type].constantize
      register       = register_class.new(meter: attrs[:meter])

      if attrs[:meta]
        register.meta = attrs[:meta]
      else
        register.build_meta(register_meta_attrs(attrs))
      end
      logger.debug("#{zaehlwerk.buzznid}: built #{register.class} with Register::Meta #{register.meta.label} (#{register.meta.name})")
      register
    end

    def log_warnings(attrs, zaehlwerk)
      logger.warn("register '#{attrs[:name]}'", zaehlwerk.warnings) if zaehlwerk.warnings.present?
      logger.warn("meter '#{attrs[:name]}'", zaehlwerk.msb_gerät.warnings) if zaehlwerk.msb_gerät.warnings.present?
    end

    def build_virtual_meter(attributes)
      with_meter_registry(attributes[:buzznid]) do
        sequence_number = if Meter::Base.where(group: @localpool).where(:sequence_number => attributes[:sequence_number]).any?
                            current_max = Meter::Base.where(group: @localpool).maximum(:sequence_number)
                            if current_max.nil?
                              raise 'this does not make any sense'
                            end
                            if current_max < @max_sequence_number
                              @max_sequence_number # + 1
                            end
                          else
                            attributes[:sequence_number]
                          end
        Meter::Virtual.new(attributes.except(:buzznid, :sequence_number).merge(sequence_number: sequence_number, legacy_buzznid: attributes[:buzznid], group: @localpool))
      end
    end

    # TODO: verify metering_point_id is stored correctly. What about metering_location? Same same?
    def build_real_meter(attributes, zaehlwerk)
      with_meter_registry(attributes[:buzznid]) do
        metering_point_id = attributes.delete(:metering_point_id)
        sequence_number = if Meter::Base.where(group: @localpool).where(:sequence_number => attributes[:sequence_number]).any?
                            current_max = Meter::Base.where(group: @localpool).maximum(:sequence_number)
                            if current_max.nil?
                              raise 'this does not make any sense'
                            end
                            if current_max < @max_sequence_number
                              @max_sequence_number # + 1
                            end
                          else
                            attributes[:sequence_number]
                          end
        meter = Meter::Real.new(attributes.except(:buzznid, :sequence_number).merge(sequence_number: sequence_number, legacy_buzznid: attributes[:buzznid], group: @localpool))
        if metering_point_id
          if metering_point_id.size != 33
            logger.warn("metering_point_id has wrong size #{metering_point_id}, expected 33", extra_data: zaehlwerk.warnings)
          else
            meter.metering_location = Meter::MeteringLocation.find_by_metering_location_id(metering_point_id) || Meter::MeteringLocation.create!(metering_location_id: metering_point_id)
          end
        end
        meter
      end
    end

    # This little lookup ensures that the registers of a two-way meter
    # are wired to the same meter record.
    def with_meter_registry(buzznid)
      @meter_registry ||= {}
      if meter = @meter_registry[buzznid]
        meter
      else
        meter = yield
        @meter_registry[buzznid] = meter
      end
    end

    def register_meta_attrs(attrs)
      attrs
        .except(:type, :meter_attributes, :metering_point_id, :meter, :readings)
        .merge(observer_enabled: false, observer_offline_monitoring: false)
    end
  end

end
