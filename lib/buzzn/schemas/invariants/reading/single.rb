module Schemas
  module Invariants
    module Reading

      Single = Schemas::Support.Form(Schemas::Constraints::Reading::Single) do

        configure do

          def higher_than_previous?(previous_reading, raw_value)
            previous_reading.nil? || raw_value >= previous_reading.raw_value
          end

          def lower_than_following?(following_reading, raw_value)
            following_reading.nil? || raw_value <= following_reading.raw_value
          end

        end

        required(:previous).maybe
        required(:following).maybe

        required(:raw_value).filled?

        rule(raw_value: [:raw_value, :previous, :following]) do |raw_value, previous, following|
          raw_value.higher_than_previous?(previous).and(raw_value.lower_than_following?(following))
        end

      end

    end
  end
end
