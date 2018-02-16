require 'active_support/concern'

class Beekeeper::Minipool::MinipoolObjekte < Beekeeper::Minipool::BaseRecord
  module Registers

    extend ActiveSupport::Concern

    private

    def registers
      msb_zählwerk_daten.reject(&:skip_import?).collect do |zählwerk|
        attrs = zählwerk.converted_attributes
        add_warning("register '#{attrs[:name]}'", zählwerk.warnings) if zählwerk.warnings.present?
        add_warning("meter '#{attrs[:name]}'", zählwerk.msb_gerät.warnings) if zählwerk.msb_gerät.warnings.present?
        register_class = attrs[:type].constantize
        register       = register_class.new(attrs.except(:type, :meter_attributes, :name))
        register.meter = find_or_build_meter(attrs[:meter_attributes])
        register.build_market_location(name: register.name)
        # debug = "#{zählwerk.buzznid}: #{register.label} (#{register.name})"
        # debug << " MPID #{register.metering_point_id}" if register.metering_point_id
        # puts debug
        register
      end
    end

    def find_or_build_meter(attributes)
      meter = Beekeeper::MeterRegistry.get(attributes[:buzznid])
      if meter
        meter
      else
        meter = Meter::Real.new(attributes.except(:buzznid).merge(legacy_buzznid: attributes[:buzznid]))
        Beekeeper::MeterRegistry.set(attributes[:buzznid], meter)
        meter
      end
    end

  end
end
