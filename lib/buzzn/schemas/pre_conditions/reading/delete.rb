require_relative '../reading'

Schemas::PreConditions::Reading::Delete = Schemas::Support.Schema do

  configure do
    def no_calculated_billing?(billing_items)
      # reject all open and void billings, if some are
      # left that means that this reading is used
      # in billings that are beyond 'calculated'
      billing_items.reject { |x| %w(open void).include?(x.billing.status) }.empty?
    end
  end

  required(:billing_items).filled

  rule(billing_items: [:billing_items]) do |billing_items|
    billing_items.no_calculated_billing?
  end

end
