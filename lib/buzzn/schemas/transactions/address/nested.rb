require_relative 'create'
require_relative 'update'

module Schemas::Transactions::Address
  module Nested

    def base
      self.const_get(:Update)
    end

    def update_for(resource)
      if resource.address
        update_with_address
      else
        update_without_address
      end
    end

    def update_with_address
      @with_address ||= Schemas::Support.Form(base) do
        optional(:address).schema(Update)
      end
    end

    def update_without_address
      @without_address ||= Schemas::Support.Form(base) do
        optional(:address).schema(Create)
      end
    end

  end
end
