class BillingCycleResource < Buzzn::EntityResource

  model BillingCycle

  attributes  :name,
              :begin_date,
              :end_date

  def billings
    object.billings.readable_by(@current_user).collect { |b| BillingResource.new(b) }
  end

  def create_regular_billings(params = {})
    object.create_regular_billings(params[:accounting_year])
  end
end