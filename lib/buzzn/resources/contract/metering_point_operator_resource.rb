require_relative 'localpool_resource'

module Contract
  class MeteringPointOperatorResource < LocalpoolResource

    model MeteringPointOperator

    attributes :metering_point_operator_name#,
               #:allowed_actionss#,
              # :incompleteness

    def allowed_actionsaxs
      allowed = []
      if allowed(permissions.pdf)
        add_allowed(allowed)
      end
      allowed
    end

    private

    def add_allowed(allowed)
      if defined? PostConditions::CreateMeteringPointOperatorPdf
        allowed << :create_pdf
      end
      if object.created_pdf
        allowed << :upload_pdf
      end
    end

  end
end
