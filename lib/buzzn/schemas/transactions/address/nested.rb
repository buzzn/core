require_relative 'create'
require_relative 'update'

module Schemas::Transactions::Address
  module Nested

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
      @with_address ||= Schemas::Support.Form(update_base) do
        optional(:address).schema(UpdateOptional)
      end
    end

    def assign_or_update_with_address
      @assign_with_address ||= Schemas::Support.Form(assign_or_update_base) do
        optional(:address).schema(UpdateOptional)
      end
    end

    def update_without_address
      @without_address ||= Schemas::Support.Form(update_base) do
        optional(:address).schema(Create)
      end
    end

    def assign_or_update_without_address
      @assign_without_address ||= Schemas::Support.Form(assign_or_update_base) do
        optional(:address).schema(Create)
      end
    end

    private

    def update_base
      self.const_get(:Update)
    end

    def assign_or_update_base
      self.const_get(:AssignOrUpdate)
    end

  end
end
