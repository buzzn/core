module Schemas
  module Invariants
    module Reading

      Single = Schemas::Support.Form(Schemas::Constraints::Reading::Single) do

        configure do

          def higher_than_previous?(previous_reading, value)
            previous_reading.nil? || value >= previous_reading.value
          end

          def lower_than_following?(following_reading, value)
            following_reading.nil? || value <= following_reading.value
          end

        end

        required(:previous).maybe
        required(:following).maybe

        required(:value).filled?
        required(:raw_value).filled?

        rule(value: [:value, :previous, :following]) do |value, previous, following|
          value.higher_than_previous?(previous).and(value.lower_than_following?(following))
        end

        rule(value: [:value, :raw_value]) do |value, raw_value|
          value(:value).eql?(value(:raw_value))
        end

      end

    end
  end
end
