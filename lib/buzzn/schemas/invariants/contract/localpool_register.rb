require_relative 'localpool'

module Schemas
  module Invariants
    module Contract

      LocalpoolRegister = Schemas::Support.Form(Localpool) do

        required(:register_meta).filled

        # be extra paranoid here
        validate(register_belongs_to_group: [:register_meta, :localpool]) do |register_meta, localpool|
          register_meta.registers.reject { |r| r.meter.group == localpool.model }.empty?
        end

      end

    end
  end
end
