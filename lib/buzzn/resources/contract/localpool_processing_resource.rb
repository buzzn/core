module Contract
  class LocalpoolProcessingResource < BaseResource

    model LocalpoolProcessing

    attributes :first_master_uid,
               :second_master_uid,
               :begin_date

  end
end
