require_relative '../constraints/billing'
module Schemas
  module Invariants

    Billing = Schemas::Support.Form(Schemas::Constraints::Billing) do
      configure do
        def match_group?(localpool, billing_cycle)
          billing_cycle.localpool == localpool.model
        end

        def lineup?(items)
          return true if items.size < 2
          sorted = items.sort_by(&:begin_date)
          next_begin_date = sorted.first.end_date
          sorted[1..-1].all? do |item|
            result = next_begin_date == item.begin_date
            next_begin_date = item.end_date
            result
          end
        end

        def covers_beginning?(begin_date, items)
          first = items.min_by(&:begin_date)
          !(first.nil? || first.begin_date > begin_date)
        end

        def covers_ending?(end_date, items)
          last = items.max do |m, n|
            result = m.end_date <=> n.end_date
            if result
              result
            else # result is nil, i.e. one end_date is nil
              m.end_date ? -1 : 1
            end
          end
          last_date = last ? last.end_date : nil
          last_date.nil? || (end_date && last_date >= end_date)
        end

        def are_complete_and_not_open?(status, items)
          # check whether items are complete
          items.all.to_a.keep_if { |item| Schemas::Completeness::Admin::BillingItem.call(Schemas::Support::ActiveRecordValidator.new(item)).errors.empty? }.count == items.count || status == 'open'
        end

      end

      required(:localpool).filled
      required(:billing_cycle).maybe
      required(:items).maybe
      required(:status).filled

      rule(localpool: [:localpool, :billing_cycle]) do |localpool, billing_cycle|
        billing_cycle.filled?.then(billing_cycle.match_group?(localpool))
      end

      rule(items: [:items, :begin_date, :end_date]) do |billing_items, begin_date, end_date|
        billing_items.covers_beginning?(begin_date).and(billing_items.covers_ending?(end_date))
      end

      rule(completeness: [:items, :status]) do |billing_items, status|
        billing_items.are_complete_and_not_open?(status)
      end

    end

  end
end
