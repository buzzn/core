require_relative '../localpool'

class Transactions::Admin::Contract::Localpool::UpdateBase < Transactions::Base

  def update_register_meta(params:, resource:, **)
    if params[:register_meta].nil?
      return
    end
    super(params: params.delete(:register_meta), resource: resource.register_meta)
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
      resource.object.register_meta_option.create(params_register_meta_options)
    else
      resource.object.register_meta_option.update(params_register_meta_options)
    end
  end

end
