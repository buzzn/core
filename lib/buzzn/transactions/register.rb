require_relative 'resource'
Buzzn::Transaction.define do |t|
  t.register_validation(:update_real_register_schema) do
    required(:updated_at).filled(:date_time?)
    optional(:metering_point_id).filled(:str?, max_size?: 32)
    optional(:name).filled(:str?, max_size?: 64)
    optional(:label).value(included_in?: Register::Base::LABELS)
    optional(:pre_decimal_position).filled(:int?, gteq?: 0)
    optional(:post_decimal_position).filled(:int?, gteq?: 0)
    optional(:low_load_ability).filled(:bool?)
    optional(:observer_enabled).filled(:bool?)
    optional(:observer_min_threshold).filled(:int?, gteq?: 0)
    optional(:observer_max_threshold).filled(:int?, gteq?: 0)
    optional(:observer_offline_monitoring).filled(:bool?)

    # TODO check the implementation of the observer and see if we need
    # such a rule
    #rule(:observer,
    #     [:observer_enabled, :observer_min_threshold, :observer_max_threshold]) do |observer_enabled, observer_min_threshold, observer_max_threshold|
    #  observer_enabled.true?.then(observer_max_threshold.gteq?(value(:observer_min_threshold))
    #end
  end

  t.register_validation(:update_virtual_register_schema) do
    required(:updated_at).filled(:date_time?)
  end

  t.define(:update_real_register) do
    validate :update_real_register_schema
    step :resource, with: :update_resource
  end

  t.define(:update_virtual_register) do
    validate :update_virtual_register_schema
    step :resource, with: :update_resource
  end
end
