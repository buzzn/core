module Schemas
  module Invariants
    module Reading

      Single = Schemas::Support.Form(Schemas::Constraints::Reading::Single) do

        configure do

          def higher_than_previous?(previous_reading, value)
            previous_reading.nil? || value >= previous_reading.value
          end

        end

        required(:previous).maybe
        required(:value).filled?

        rule(value: [:value, :previous]) do |value, previous|
          value.higher_than_previous?(previous)
        end

      end

    end
  end
end
