require_relative 'base_resource'
require_relative '../group_resource'

module Contract
  class LocalpoolResource < BaseResource

    has_one :localpool, GroupResource

  end
end
