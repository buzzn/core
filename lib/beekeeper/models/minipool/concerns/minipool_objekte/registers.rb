require 'active_support/concern'

class Beekeeper::Minipool::MinipoolObjekte < Beekeeper::Minipool::BaseRecord
  module Registers

    extend ActiveSupport::Concern

    private

    def registers
      msb_zählwerk_daten.reject(&:skip_import?).map do |zählwerk|
        attrs = zählwerk.converted_attributes
        add_warning("register '#{attrs[:name]}'", zählwerk.warnings) if zählwerk.warnings.present?
        add_warning("meter '#{attrs[:name]}'", zählwerk.msb_gerät.warnings) if zählwerk.msb_gerät.warnings.present?
        register_class = attrs[:type].constantize
        register       = register_class.new(attrs.except(:type, :meter_attributes))
        register.meter = find_or_build_meter(attrs[:meter_attributes])
        # debug = "#{zählwerk.buzznid}: #{register.label} (#{register.name})"
        # debug << " MPID #{register.metering_point_id}" if register.metering_point_id
        # puts debug
        register
      end
    end

    def find_or_build_meter(attributes)
      raise "buzznid unreliable!!" if attributes[:buzznid] !~ /^([0-9])+\/([0-9])+$/
      @@meters ||= {} # very ugly, err, I mean pragmatic
      if @@meters[attributes[:buzznid]]
        # puts "Reusing existing meter instance for buzznid #{attributes[:buzznid]} (serial #{attributes[:product_serialnumber]})"
        @@meters[attributes[:buzznid]]
      else
        # puts "Making new meter instance buzznid #{attributes[:buzznid]} (serial #{attributes[:product_serialnumber]})"
        @@meters[attributes[:buzznid]] = Meter::Real.new(attributes.except(:buzznid))
      end
    end
  end
end