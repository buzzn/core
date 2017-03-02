module Contract
  class LocalpoolProcessingResource < BaseResource
    model_name 'Contract::LocalpoolProcessing'

    attributes  :first_master_uid,
                :second_master_uid,
                :begin_date

  end
end
