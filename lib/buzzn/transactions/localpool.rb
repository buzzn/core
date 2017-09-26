require_relative 'resource'
Buzzn::Transaction.define do |t|
  t.register_validation(:create_localpool_schema) do
    required(:name).filled(:str?, max_size?: 64)
    optional(:description).filled(:str?, max_size?: 256)
  end

  t.register_validation(:update_localpool_schema) do
    required(:updated_at).filled(:date_time?)
    optional(:name).filled(:str?, max_size?: 64)
    optional(:description).filled(:str?, max_size?: 256)
  end

  t.define(:create_localpool) do
    validate :create_localpool_schema
    step :resource, with: :nested_resource
  end

  t.define(:update_localpool) do
    validate :update_localpool_schema
    step :resource, with: :update_resource
  end
end
