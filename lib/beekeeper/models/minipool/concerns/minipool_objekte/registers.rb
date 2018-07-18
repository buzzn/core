require 'active_support/concern'

class Beekeeper::Minipool::MinipoolObjekte < Beekeeper::Minipool::BaseRecord
  module Registers

    extend ActiveSupport::Concern

    private

    SUBSTITUTE_BUZZNID = ['90043/1', '90005/5', '90051/9', '90052/12']

    def registers
      substitute_registers + real_registers
    end

    def substitute_registers
      zählwerke = msb_zählwerk_daten.select(&:skip_import?).select do |zählwerk|
        SUBSTITUTE_BUZZNID.include?(zählwerk.buzznid)
      end
      zählwerke.collect do |zählwerk|
        attrs = zählwerk.converted_attributes.slice(:label, :share_with_group, :share_publicly, :name, :meter_attributes)
        attrs[:type] = 'Register::Substitute'
        attrs[:meter] = build_virtual_meter(attrs[:meter_attributes].slice(:sequence_number, :buzznid))

        build_register(attrs, zählwerk)
      end
    end

    def build_register(attrs, zählwerk)
      add_warnings(attrs, zählwerk)
      register_class = attrs[:type].constantize
      # note: during the import we move the name from the register (zählwerk) to the newly introduced entity
      register       = register_class.new(attrs.except(:type, :meter_attributes, :name))
      register.build_market_location(name: attrs[:name])
      # debug = "#{zählwerk.buzznid}: #{register.label} (#{register.name})"
      # debug << " MPID #{register.metering_point_id}" if register.metering_point_id
      # puts debug
      register
    end

    def build_virtual_meter(attributes)
      meter = Meter::Virtual.new(attributes.except(:buzznid).merge(legacy_buzznid: attributes[:buzznid]))
      Beekeeper::MeterRegistry.set(attributes[:buzznid], meter)
      meter
    end

    def real_registers
      msb_zählwerk_daten.reject(&:skip_import?).collect do |zaehlwerk|
        attrs = zaehlwerk.converted_attributes
        add_warnings(attrs, zaehlwerk)
        attrs[:meter] = find_or_build_meter(attrs[:meter_attributes])
        build_register(attrs, zaehlwerk)
      end
    end

    def add_warnings(attrs, zählwerk)
      add_warning("register '#{attrs[:name]}'", zählwerk.warnings) if zählwerk.warnings.present?
      add_warning("meter '#{attrs[:name]}'", zählwerk.msb_gerät.warnings) if zählwerk.msb_gerät.warnings.present?
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
