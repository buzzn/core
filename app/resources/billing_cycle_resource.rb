class BillingCycleResource < Buzzn::EntityResource

  model BillingCycle

  attributes  :name,
              :begin_date,
              :end_date

  def billings
    object.billings.readable_by(@current_user).collect { |b| BillingResource.new(b) }
  end

  def create_regular_billings(accounting_year:)
    object.create_regular_billings(accounting_year).collect { |b| BillingResource.new(b) }
  end

  def billing(id)
    BillingResource.retrieve(current_user, id)
  end
end
