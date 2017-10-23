module Buzzn
  module Roda
    class ErrorHandler < Proc

      ERRORS = {
        Buzzn::RecordNotFound => 404,
        Buzzn::PermissionDenied => 403,
        Buzzn::StaleEntity => 409,
        Buzzn::ValidationError => 422,
        Buzzn::GeneralError => 404
      }

      def self.new(logger: Logger.new(self))
        super() do |e|
          response.status = ERRORS[e.class] || 500
          response['Content-Type'] = 'application/json'

          case e
          when Buzzn::ValidationError
            errs = []
            e.errors.each do |name, messages|
              messages.each do |message|          
                errs << "{\"parameter\":\"#{name}\",\"detail\":\"#{message}\"}"
              end
            end
            errors = "{\"errors\":[#{errs.join(',')}]}"
            logger.debug{ errors.to_s }
          when Buzzn::PermissionDenied, Buzzn::RecordNotFound, Buzzn::StaleEntity
            errors = "{\"errors\":[{\"detail\":\"#{e.message}\"}]}"
            logger.info{ errors.to_s }
          else
            logger.error{ "#{e.message}\n\t" + e.backtrace.join("\n\t")}
            errors = "{\"errors\":[{\"detail\":\"internal server error\"}]}"
          end
          if response.status == 500
          else
          end
          response.write(errors)
        end
      end
    end
  end
end
