require_relative '../../constraints/register/base'
require_relative '../../constraints/register/meta'

module Schemas
  module Invariants
    module Register

      Meta = Schemas::Support.Form(Schemas::Constraints::Register::Meta) do

        rule(observer: [:observer_enabled, :observer_min_threshold, :observer_max_threshold]) do |observer_enabled, observer_min_threshold, observer_max_threshold|
          observer_enabled.true?.then(observer_max_threshold.filled?.and(observer_min_threshold.filled?).and(observer_max_threshold.gteq?(value(:observer_min_threshold))))
        end

      end

      Base = Schemas::Support.Form(Schemas::Constraints::Register::Base) do

        configure do

          # WARNING: as of now, our readings don't always grow over time. Reason:
          # beekeeper had no notion of metering locations, and thus couldn't model it's register changes.
          # Thus all imported readings are stored on the current (and only) register of a metering location, even when
          # the register was swapped at some point. And the readings of a new register typically start much lower.

          # NOTE: if this really create problems with legacy data we can disable this.
          def grow_in_time?(readings)
            readings.sort_by(&:date) == readings.sort_by(&:value)
          end
        end

        required(:readings).filled { grow_in_time? }
        required(:meta_for_invariant).schema(Meta)

      end

    end
  end
end
