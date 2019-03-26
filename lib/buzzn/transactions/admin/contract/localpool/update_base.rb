require_relative '../localpool'

class Transactions::Admin::Contract::Localpool::UpdateBase < Transactions::Base

  def update_register_meta(params:, resource:, **)
    if params[:register_meta].nil?
      return
    end
    super(params: params.delete(:register_meta), resource: resource.register_meta)
  end

  def update_tax_data(params:, resource:, **)
    tax_data = if resource.tax_data.nil?
                 Contract::TaxData.new
               else
                 resource.object.tax_data
               end
    if params[:tax_number]
      tax_data.tax_number = params.delete(:tax_number)
    end
    if params[:creditor_identification]
      tax_data.creditor_identification = params.delete(:creditor_identification)
    end
    if params[:sales_tax_number]
      tax_data.sales_tax_number = params.delete(:sales_tax_number)
    end
    tax_data.save
    params[:tax_data] = tax_data
  end

  def update_register_meta_options(params:, resource:, **)
    params_register_meta_options = {}
    unless params[:share_register_publicly].nil?
      params_register_meta_options[:share_publicly] = params.delete(:share_register_publicly)
    end
    unless params[:share_register_with_group].nil?
      params_register_meta_options[:share_with_group] = params.delete(:share_register_with_group)
    end
    if resource.object.register_meta_option.nil?
      params_register_meta_options[:share_publicly] ||= false
      params_register_meta_options[:share_with_group] ||= false
      params[:register_meta_option] = Register::MetaOption.create(params_register_meta_options)
    else
      resource.object.register_meta_option.update(params_register_meta_options)
    end
  end

end
