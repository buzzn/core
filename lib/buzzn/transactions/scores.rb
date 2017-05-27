class Buzzn::Transaction

  define do |t|

    t.register_validation(:scores_schema) do
      required(:interval)
        .value(included_in?: ['year', 'month', 'day'])
      required(:timestamp)
        .filled(:time?)
      optional(:mode)
        .value(included_in?: ['sufficiency', 'closeness', 'autarchy', 'fitting'])
    end

    t.define(:scores) do
      validate :scores_schema
      step :resource, with: :nested_resource
    end
  end
end
