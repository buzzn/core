require_relative '../contract'

module Schemas::PreConditions::Contract

  CreateBilling = Schemas::Support.Schema do

    required(:tariffs).value(min_size?: 1)

    required(:register_meta).schema do
      configure do
        def all_registers_installed?(registers)
          # FIXME: speed up
          registers.to_a.keep_if { |r| r.readings.installed.any? }.count == registers.count
        end
      end

      required(:registers).value(min_size?: 1).true?.then(value(:registers).all_registers_installed?)
    end

  end

end
