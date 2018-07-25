require_relative 'localpool_resource'

module Contract
  class LocalpoolProcessingResource < LocalpoolResource

    model LocalpoolProcessing

    attributes :begin_date
    attributes :tax_number

    has_one :contractor
    has_one :customer

  end
end
