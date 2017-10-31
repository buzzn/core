require_relative '../../constraints/contract/base'
module Schemas
  module Invariants
    module Contract
      Base = Buzzn::Schemas.Form(Schemas::Constraints::Register::Base) do
        required(:observer_enabled).maybe
        required(:observer_min_threshold).maybe
        required(:observer_max_threshold).maybe

        rule(:observer_enabled, [:observer_enabled, :observer_min_threshold, :observer_max_threshold]) do |observer_enabled, observer_min_threshold, observer_max_threshold|
          observer_enabled.true?.then(observer_max_threshold.filled?.and(observer_min_threshold.filled?).and(observer_max_threshold.gteq?(value(:observer_min_threshold))))
        end
      end
    end
  end
end
