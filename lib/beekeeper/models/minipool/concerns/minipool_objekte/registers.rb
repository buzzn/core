require 'active_support/concern'

class Beekeeper::Minipool::MinipoolObjekte < Beekeeper::Minipool::BaseRecord
  module Registers

    extend ActiveSupport::Concern

    private

    def registers
      msb_zählwerk_daten.map do |zählwerk|
        attrs = zählwerk.converted_attributes
        register_class = attrs[:type].constantize
        register_class.new(attrs.except(:type))
      end
    end

  end
end
