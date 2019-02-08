
class Beekeeper::Importer::Readings

  attr_reader :logger

  SUBSTITUTE_BUZZNID = ['90043/1', '90005/5', '90051/9', '90052/12']

  def initialize(logger)
    @logger = logger
    @logger.section = 'create-readings'
  end

  # TODO: check if readings have already been created
  # TODO: assign localpool
  def run(localpool, record)
    # - for each register
    record.msb_zählwerk_daten.each do |zaehlwerk|
      all_registers = []
      current_register = create_register(zaehlwerk)
      # all_registers << current_register
      # zaehlwerk.readings.sort_by(&:date).reverse.each do |reading|
      #   begin
      #     puts "* Zählwerk: #{zaehlwerk.buzznid}"
      #     if reading.reason == 'device_change_2'
      #       current_register = create_register(current_register)
      #       all_registers << current_register
      #       puts "#{reading.date.iso8601} #{reading.reason_code} #{reading.value.to_s.rjust(10, ' ')}"
      #     end
      #     current_register.readings << reading
      #   rescue StandardError => e
      #     logger.error("Failed to create reading: #{e.message}", extra_data: e)
      #     next
      #   end
      # end
      # TODO: re-assign all metas!
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
        if SUBSTITUTE_BUZZNID.include?(zaehlwerk.buzznid)
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
    # TODO: check if it can be changed to also use build_any_register
    def build_fake_register(zaehlwerk)
      fake_meter_name = "FAKE-FOR-IMPORT-#{counter}"
      meter = Meter::Real.create!(product_serialnumber: fake_meter_name, legacy_buzznid: zaehlwerk.buzznid)
      meta = Register::Meta.new(name: fake_meter_name.gsub('IMPORT-', 'IMPORT-M-'), label: :other, observer_enabled: false, observer_offline_monitoring: false)
      Register::Real.create!(meta: meta, meter: meter)
    end

    def build_real_register(zaehlwerk)
      attrs = zaehlwerk.converted_attributes
      log_warnings(attrs, zaehlwerk)
      attrs[:meter] = find_or_build_meter(attrs[:meter_attributes], zaehlwerk)
      build_any_register(attrs, zaehlwerk)
    end

    def counter
      $counter = $counter.to_i + 1
    end

    private

    # TODO: pass in the meta when we already created one
    def build_any_register(attrs, zaehlwerk)
      log_warnings(attrs, zaehlwerk)
      register_class = attrs[:type].constantize
      # note: during the import we move the name from the register (zaehlwerk) to the newly introduced entity
      register       = register_class.new(attrs.slice(:readings, :meter))

      register_meta_default_attrs = { :observer_enabled => false, :observer_offline_monitoring => false }
      register.build_meta(attrs.except(:type, :meter_attributes, :metering_point_id, :meter, :readings).merge(register_meta_default_attrs))
      # logger.debug("#{zaehlwerk.buzznid}: #{register.label} (#{register.name}). MPID: '#{register.metering_point_id}'")
      register
    end

    def log_warnings(attrs, zaehlwerk)
      logger.warn("register '#{attrs[:name]}'", zaehlwerk.warnings) if zaehlwerk.warnings.present?
      logger.warn("meter '#{attrs[:name]}'", zaehlwerk.msb_gerät.warnings) if zaehlwerk.msb_gerät.warnings.present?
    end

    def build_virtual_meter(attributes)
      meter = Meter::Virtual.new(attributes.except(:buzznid).merge(legacy_buzznid: attributes[:buzznid]))
      Beekeeper::MeterRegistry.set(attributes[:buzznid], meter)
      meter
    end

    def find_or_build_meter(attributes, zaehlwerk)
      meter = Beekeeper::MeterRegistry.get(attributes[:buzznid])
      if meter
        meter
      else
        metering_point_id = attributes.delete(:metering_point_id)
        meter = Meter::Real.new(attributes.except(:buzznid).merge(legacy_buzznid: attributes[:buzznid]))
        if metering_point_id
          if metering_point_id.size != 33
            logger.warn("metering_point_id has wrong size #{metering_point_id}, expected 33", extra_data: zaehlwerk.warnings)
          else
            meter.metering_location = Meter::MeteringLocation.create!(metering_location_id: metering_point_id)
          end
        end
        Beekeeper::MeterRegistry.set(attributes[:buzznid], meter)
        meter
      end
    end

  end
end
