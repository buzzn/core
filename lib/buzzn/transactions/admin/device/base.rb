require_relative '../device'

class Transactions::Admin::Device::Base < Transactions::Base

  def assign_electricity_supplier(params:, **)
    if id = (params[:electricity_supplier] || {})[:id]
      params[:electricity_supplier] = Organization::Market.electricity_suppliers.where(id: id).first
    end
  end

end
