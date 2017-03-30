module Contract
  class LocalpoolProcessingResource < BaseResource

    model LocalpoolProcessing

    attributes :first_master_uid,
               :second_master_uid,
               :begin_date

  end

  # TODO get rid of the need of having a Serializer class
  class LocalpoolProcessingSerializer < LocalpoolProcessingResource
    def self.new(*args)
      super
    end
  end
end
