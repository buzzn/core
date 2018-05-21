require_relative 'base_resource'
require_relative '../admin/localpool_resource'

module Contract
  class LocalpoolResource < BaseResource

    # TODO why generic GroupResource. is hits really needed by UI?
    has_one :localpool, GroupResource

  end
end
