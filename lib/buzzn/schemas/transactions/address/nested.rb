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

    def assign_or_update_for(resource)
      if resource.address
        assign_or_update_with_address
      else
        assign_or_update_without_address
      end
    end

    def update_with_address
      @with_address ||= Schemas::Support.Form(base) do
        optional(:address).schema(Update)
      end
    end

    def assign_or_update_with_address
      @assign_with_address ||= Schemas::Support.Form(base) do
        optional(:id).filled(:int?)
        optional(:address).schema(Update)
      end
    end

    def update_without_address
      @without_address ||= Schemas::Support.Form(base) do
        optional(:address).schema(Create)
      end
    end

    def assign_or_update_without_address
      @assign_without_address ||= Schemas::Support.Form(base) do
        optional(:id).filled(:int?)
        optional(:address).schema(Create)
      end
    end

  end
end
