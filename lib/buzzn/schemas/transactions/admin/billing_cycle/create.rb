require_relative '../../../constraints/billing_cycle'
require_relative '../billing_cycle'

Schemas::Transactions::Admin::BillingCycle::Create = Schemas::Constraints::BillingCycle
