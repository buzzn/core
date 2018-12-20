require_relative 'base'
module Transactions::Admin::Reading::Request
  class Read < Base

    validate :schema
    authorize :allowed_roles
    tee :check_resource
    add :set_create
    add :fetch_reading
    map :wrap_up

    def set_create(**)
      false
    end

    def wrap_up(params:, resource:, fetch_reading:, **)
      ReadingResource.new(fetch_reading)
    end

  end
end
