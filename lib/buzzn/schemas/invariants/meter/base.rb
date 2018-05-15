require_relative '../../constraints/meter/base'

module Schemas
  module Invariants
    module Meter

      Base = Schemas::Support.Form(Schemas::Constraints::Meter::Base) do

        configure do
          def match_group?(group, registers)
            registers.all? { |register| register.group.nil? || register.group == group }
          end
        end

        required(:group).maybe
        required(:registers).filled
        required(:manufacturer_name).filled
        required(:edifact_measurement_method).filled
        required(:datasource).filled

        rule(:manufacturer_name) do
          value(:datasource).eql?('discovergy').then(value(:manufacturer_name).eql?('easy_meter'))
        end

        rule(:edifact_measurement_method) do
          value(:datasource)
            .eql?('discovergy').then(value(:edifact_measurement_method).eql?('AMR'))
            .and(value(:datasource).eql?('standard_profile').then(value(:edifact_measurement_method).eql?('MMR')))
        end

        rule(:datasource) do
          value(:edifact_measurement_method)
            .eql?('AMR').then(value(:datasource).eql?('discovergy'))
            .and(value(:edifact_measurement_method).eql?('MMR').then(value(:datasource).eql?('standard_profile')))
        end

        rule(group: [:group, :registers]) do |group, registers|
          group.filled?.then(registers.match_group?(group))
        end
      end

    end
  end
end
