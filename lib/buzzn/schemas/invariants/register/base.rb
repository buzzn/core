require_relative '../../constraints/register/base'

module Schemas
  module Invariants
    module Register

      Base = Schemas::Support.Form(Schemas::Constraints::Register::Base) do

        configure do
          def match_group?(group, meter)
            meter.group && meter.group == group
          end

          def grow_in_time?(readings)
            readings.sort_by(&:date) == readings.sort_by(&:value)
          end
        end

        required(:observer_enabled).maybe
        required(:observer_min_threshold).maybe
        required(:observer_max_threshold).maybe
        required(:group).maybe
        required(:readings).filled { grow_in_time? }
        required(:meter).filled

        rule(observer_enabled: [:observer_enabled, :observer_min_threshold, :observer_max_threshold]) do |observer_enabled, observer_min_threshold, observer_max_threshold|
          observer_enabled.true?.then(observer_max_threshold.filled?.and(observer_min_threshold.filled?).and(observer_max_threshold.gteq?(value(:observer_min_threshold))))
        end

        rule(group: [:group, :meter]) do |group, meter|
          group.filled?.then(meter.match_group?(group))
        end
      end

    end
  end
end
