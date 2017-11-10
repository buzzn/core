module Schemas
  module Completeness
    Organization = Buzzn::Schemas.Schema do
      required(:contact).filled
    end
  end
end
