require_relative 'localpool_resource'

module Contract
  class LocalpoolProcessingResource < LocalpoolResource

    model LocalpoolProcessing

    attributes :begin_date,
               :tax_number,
               :allowed_actions

    has_one :contractor
    has_one :customer

    def allowed_actions
      allowed = {}
      if allowed?(permissions.document)
        allowed[:document_localpool_processing_contract] = document_localpool_processing_contract.success? || document_localpool_processing_contract.errors
      end
      allowed
    end

    def document_localpool_processing_contract
      subject = Schemas::Support::ActiveRecordValidator.new(self.object)
      Schemas::PreConditions::Contract::DocumentLocalpoolProcessingContract.call(subject)
    end

  end
end
