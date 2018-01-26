require_relative 'localpool_resource'

module Contract
  class LocalpoolProcessingResource < LocalpoolResource

    model LocalpoolProcessing

    attributes :begin_date

  end
end
