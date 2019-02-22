require_relative '../../constraints/meter/base'

module Schemas
  module Invariants
    module Meter

      Base = Schemas::Support.Form(Schemas::Constraints::Meter::Base) do

        required(:registers).filled
        required(:manufacturer_name).filled
        required(:edifact_measurement_method).filled
        required(:datasource).filled
        required(:converter_constant).value(:int?, gteq?: 1)

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

      end

    end
  end
end
