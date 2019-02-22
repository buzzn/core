require './app/models/reading/single.rb'

module Schemas
  module Invariants
    module Reading

      Single = Schemas::Support.Form do

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

        required(:raw_value).filled(:bigint?)
        required(:value).filled(:bigint?)
        required(:unit).value(included_in?: ::Reading::Single.units.values)
        required(:reason).value(included_in?: ::Reading::Single.reasons.values)
        required(:read_by).value(included_in?: ::Reading::Single.read_by.values)
        required(:quality).value(included_in?: ::Reading::Single.qualities.values)
        required(:source).value(included_in?: ::Reading::Single.sources.values)
        required(:status).value(included_in?: ::Reading::Single.status.values)
        required(:date).filled(:date?)
        optional(:comment).maybe(:str?, max_size?: 256)

        rule(raw_value: [:raw_value, :previous, :following]) do |raw_value, previous, following|
          raw_value.higher_than_previous?(previous).and(raw_value.lower_than_following?(following))
        end

      end

    end
  end
end
