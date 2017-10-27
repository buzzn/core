require_relative 'resource'
require_relative '../schemas/constraints/person'

Buzzn::Transaction.define do |t|
  t.register_validation(:create_localpool_schema) do
    required(:name).filled(:str?, max_size?: 64)
    optional(:description).filled(:str?, max_size?: 256)
    optional(:start_date).filled(:date?)
    optional(:show_object).filled(:bool?)
    optional(:show_production).filled(:bool?)
    optional(:show_energy).filled(:bool?)
    optional(:show_contact).filled(:bool?)
  end

  t.register_validation(:update_localpool_schema) do
    required(:updated_at).filled(:date_time?)
    optional(:name).filled(:str?, max_size?: 64)
    optional(:description).filled(:str?, max_size?: 256)
    optional(:start_date).filled(:date?)
    optional(:show_object).filled(:bool?)
    optional(:show_production).filled(:bool?)
    optional(:show_energy).filled(:bool?)
    optional(:show_contact).filled(:bool?)
  end

  t.define(:create_localpool) do
    validate :create_localpool_schema
    step :resource, with: :nested_resource
  end

  t.define(:create_localpool_owner) do
    step :validate, with: :constraints
    step :build, with: :build
    step :assign, with: :method
  end

  t.define(:assign_localpool_owner) do
    step :find, with: :retrieve
    step :assign, with: :method
  end

  t.define(:update_localpool) do
    validate :update_localpool_schema
    step :resource, with: :update_resource
  end
end
