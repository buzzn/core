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

      def self.new
        super do |e|
          response.status = ERRORS[e.class] || 500
          response['Content-Type'] = 'application/json'
          puts "#{e.message}\n\t" + e.backtrace.join("\n\t") if response.status == 500
          title = e.class.to_s.sub(/.*::/, '').underscore.split(/_/).collect{|c| c.capitalize}.join(' ')

          case e
          when Buzzn::ValidationError
            errs = []
            e.errors.each do |name, messages|
              messages.each do |message|          
                errs << "{\"parameter\":\"#{name}\",\"detail\":\"#{message}\"}"
              end
            end
            errors = "{\"errors\":[#{errs.join(',')}]}"
          when Buzzn::PermissionDenied, Buzzn::RecordNotFound, Buzzn::StaleEntity
            errors = "{\"errors\":[{\"detail\":\"#{e.message}\"}]}"
          else
            errors = "{\"errors\":[{\"detail\":\"internal server error\"}]}"
          end
          response.write(errors)
        end
      end
    end
  end
end
