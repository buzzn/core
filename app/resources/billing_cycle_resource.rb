class BillingCycleResource < Buzzn::Resource::Entity

  model BillingCycle

  attributes  :name,
              :begin_date,
              :end_date

  has_many :billings

  def create_regular_billings(accounting_year:)
    to_collection(object.create_regular_billings(accounting_year))
  end
end
