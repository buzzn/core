
class Beekeeper::Importer::ReadingsRegistersMeters

  attr_reader :logger

  KNOWN_SUBSTITUTE_REGISTERS = ['90043/1', '90005/5', '90051/9', '90052/12']

  def initialize(logger)
    @logger = logger
    @logger.section = 'readings-registers-meters'
  end

  # TODO: check if readings have already been created previously in the import
  # TODO: ensure creation of localpool contracts still works
  # TODO: assign localpool
  # TODO: assign all registers of a to the same meta-register (all registers created for on one zaehlwerk)
  # TODO: rescue errors fine-grained
  # TODO: clarify why the "Canary Test Group" doesn't import properly
  def run(localpool, record)
    puts "#{localpool.name} has #{record.msb_zählwerk_daten.size} zaehlwerke"
    for_each_zaehlwerk(record) do |zaehlwerk, zaehlwerk_readings|
      register = create_register(zaehlwerk)
      # puts "* Zählwerk: #{zaehlwerk.buzznid} --> #{register.class}"
      zaehlwerk_readings.each do |reading|
        # puts "#{reading.date.iso8601} #{reading.reason_code} #{reading.value.to_s.rjust(10, ' ')}"
        register.readings << reading
      #     if reading.reason == 'device_change_2'
      #       register = create_register(register)
      #     end
      end
      puts "Created #{zaehlwerk_readings.size} readings"
      register # important to return this!
    end
    # puts "Created #{all_registers.size} registers"
  end

  private

  def for_each_zaehlwerk(record)
    record.msb_zählwerk_daten.map do |zaehlwerk|
      yield [
        zaehlwerk,
        zaehlwerk.converted_attributes[:readings].sort_by(&:date).reverse
      ]
    end
  end

  def create_register(zaehlwerk)
    @builder ||= RegisterBuilder.new(logger)
    register = @builder.build_register(zaehlwerk)
    register.save!
    register
  end

  # The following is copy-pasted from Beekeeper::Minipool::MinipoolObjekte::Registers
  class RegisterBuilder

    attr_reader :logger

    def initialize(logger)
      @logger = logger
    end

    def build_register(zaehlwerk)
      if zaehlwerk.virtual?
        if KNOWN_SUBSTITUTE_REGISTERS.include?(zaehlwerk.buzznid)
          build_substitute_register(zaehlwerk)
        else
          logger.warn("No meter/register for #{zaehlwerk.buzznid}, creating a fake temporary one.", extra_data: zaehlwerk)
          build_fake_register(zaehlwerk)
        end
      else
        build_real_register(zaehlwerk)
      end
    end

    def build_substitute_register(zaehlwerk)
      attrs = zaehlwerk.converted_attributes.slice(:label, :name, :meter_attributes)
      attrs[:type] = 'Register::Substitute'
      attrs[:meter] = build_virtual_meter(attrs[:meter_attributes].slice(:sequence_number, :buzznid))
      build_any_register(attrs, zaehlwerk)
    end

    # As a temporary solution to importing the actual virtual registers (separate story), we create a fake, empty one.
    # TODO: check if method can be changed to also use build_any_register
    def build_fake_register(zaehlwerk)
      fake_meter_name = "FAKE-FOR-IMPORT-#{fake_register_counter}"
      meter = Meter::Real.create!(product_serialnumber: fake_meter_name, legacy_buzznid: zaehlwerk.buzznid)
      meta = Register::Meta.new(name: fake_meter_name.gsub('IMPORT-', 'IMPORT-M-'), label: :other, observer_enabled: false, observer_offline_monitoring: false)
      Register::Real.create!(meta: meta, meter: meter)
    end

    def build_real_register(zaehlwerk)
      attrs = zaehlwerk.converted_attributes
      attrs[:meter] = build_real_meter(attrs[:meter_attributes], zaehlwerk)
      build_any_register(attrs, zaehlwerk)
    end

    def fake_register_counter
      $counter = $counter.to_i + 1
    end

    private

    def build_any_register(attrs, zaehlwerk)
      log_warnings(attrs, zaehlwerk)
      register_class = attrs[:type].constantize
      # note: during the import we move the name from the register (zaehlwerk) to the newly introduced entity
      register       = register_class.new(attrs.slice(:readings, :meter))

      register_meta_default_attrs = { :observer_enabled => false, :observer_offline_monitoring => false }
      register.build_meta(attrs.except(:type, :meter_attributes, :metering_point_id, :meter, :readings).merge(register_meta_default_attrs))
      logger.debug("#{zaehlwerk.buzznid}: created #{register.class} with meter #{register.meter}")
      logger.debug("#{zaehlwerk.buzznid}: created Register::Meta: #{register.meta.label} (#{register.meta.name})")
      register
    end

    def log_warnings(attrs, zaehlwerk)
      logger.warn("register '#{attrs[:name]}'", zaehlwerk.warnings) if zaehlwerk.warnings.present?
      logger.warn("meter '#{attrs[:name]}'", zaehlwerk.msb_gerät.warnings) if zaehlwerk.msb_gerät.warnings.present?
    end

    def build_virtual_meter(attributes)
      with_meter_registry(attributes[:buzznid]) do
        Meter::Virtual.new(attributes.except(:buzznid).merge(legacy_buzznid: attributes[:buzznid]))
      end
    end

    # TODO: verify metering_point_id is stored correctly. What about metering_location? Same same?
    def build_real_meter(attributes, zaehlwerk)
      with_meter_registry(attributes[:buzznid]) do
        metering_point_id = attributes.delete(:metering_point_id)
        meter = Meter::Real.new(attributes.except(:buzznid).merge(legacy_buzznid: attributes[:buzznid]))
        if metering_point_id
          if metering_point_id.size != 33
            logger.warn("metering_point_id has wrong size #{metering_point_id}, expected 33", extra_data: zaehlwerk.warnings)
          else
            meter.metering_location = Meter::MeteringLocation.create!(metering_location_id: metering_point_id)
          end
        end
        meter
      end
    end

    def with_meter_registry(buzznid)
      if meter = meter_registry.get(buzznid)
        meter
      else
        meter = yield
        meter_registry.set(buzznid, meter)
        meter
      end
    end

    # TODO: maybe the external class isn't needed any more. It used to be, since
    # the meters were needed from different import classes
    def meter_registry
      Beekeeper::MeterRegistry
    end

  end
end
