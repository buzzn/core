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

      required(:registers).value(min_size?: 1)

      rule(registers: [:registers]) do |registers|
        registers.all_registers_installed?
      end

      # TODO make this work:
      #required(:registers).value(min_size?: 1).each do
      #  schema do
      #    configure do
      #      def installed?(readings)
      #        readings.installed.any?
      #      end
      #    end
      #    required(:readings).value(min_size?: 1).installed?
      #  end
      #end

    end

  end

end
