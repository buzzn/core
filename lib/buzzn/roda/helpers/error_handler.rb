module Buzzn
  module Roda
    class ErrorHandler < Proc

      ERRORS = {
        Buzzn::RecordNotFound => 404,
        Buzzn::PermissionDenied => 403,
        Buzzn::StaleEntity => 409,
        Buzzn::ValidationError => 422,
        Buzzn::GeneralError => 404,
        Buzzn::DataSourceError => 503,
        Buzzn::RemoteNotFound => 404,
        ::Services::Datasource::Discovergy::Api::EmptyResponse => 404
      }

      def self.new(logger: Logger.new(self))
        super() do |e|
          response.status = ERRORS[e.class] || raise(e)

          case e
          when Buzzn::ValidationError, Buzzn::RemoteNotFound
            logger.debug{ e.errors.inspect }
            errors = e.errors.to_json
            response['Content-Type'] = 'application/json'
            response.write(
              e.json)
          when Buzzn::PermissionDenied, Buzzn::RecordNotFound, Buzzn::StaleEntity
            logger.info{ e.message }
          else
            logger.error{ "#{e.message}\n\t" + e.backtrace.join("\n\t")}
          end
          # return an empty string
          ""
        end
      end

    end
  end
end
