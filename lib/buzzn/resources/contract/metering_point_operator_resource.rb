require_relative 'localpool_resource'
require_relative '../../schemas/pre_conditions/contract/document_metering_point_operator_contract'

module Contract
  class MeteringPointOperatorResource < LocalpoolResource

    model MeteringPointOperator

    attributes :begin_date,
               :allowed_actions,
               :metering_point_operator_name

    has_one :contractor
    has_one :customer

    def allowed_actions
      allowed = {}
      if allowed?(permissions.document)
        allowed[:document_metering_point_operator_contract] = document_metering_point_operator_contract.success? || document_metering_point_operator_contract.errors
      end
      allowed
    end

    def document_metering_point_operator_contract
      subject = Schemas::Support::ActiveRecordValidator.new(self.object)
      Schemas::PreConditions::Contract::DocumentMeteringPointOperatorContract.call(subject)
    end

  end
end
