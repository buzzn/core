require_relative '../../constraints/contract/base'
module Schemas
  module Invariants
    module Contract

      Base = Schemas::Support.Form(Schemas::Constraints::Contract::Base) do
        optional(:termination_date).maybe
        optional(:end_date).maybe

        rule(begin_date: [:begin_date, :termination_date, :end_date]) do |begin_date, termination_date, end_date|
          end_date.filled?.or(termination_date.filled?).then begin_date.filled?
        end

        rule(termination_date: [:termination_date, :end_date]) do |termination_date, end_date|
          end_date.filled?.then termination_date.filled?
        end
      end

    end
  end
end
