class Buzzn::Transaction
  define do |t|

    t.register_validation(:charts_schema) do
      required(:duration).value(included_in?: ['year', 'month', 'day', 'hour'])
      optional(:timestamp).filled(:time?)
    end
    
    t.define(:charts) do
      validate :charts_schema
      step :resource, with: :nested_resource
    end
  end
end
