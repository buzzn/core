module Schemas
  module Completeness
    Organization = Dry::Validation.Schema do
      required(:contact).filled
    end
  end
end
