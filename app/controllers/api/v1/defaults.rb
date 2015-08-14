module API
  module V1
    module Defaults
      extend ActiveSupport::Concern
      included do
        prefix "api"
        version "v1", using: :path
        default_format :json
        formatter :json, Grape::Formatter::ActiveModelSerializers

        helpers do

          def status_400
            error!('Bad Request', 400)
          end

          def status_401
            error!('Unauthorized', 401)
          end

          def status_403
            error!('Forbidden', 403)
          end

          def status_404
            error!('Not Found', 404)
          end

          def permitted_params
            @permitted_params ||= declared(params, include_missing: false)
          end

          def logger
            Rails.logger
          end
        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          error_response(message: e.message, status: 404)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          error_response(message: e.message, status: 422)
        end
      end
    end
  end
end