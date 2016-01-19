module API
  module V1
    module Defaults
      extend ActiveSupport::Concern
      included do
        prefix "api"
        version "v1", using: :path
        format 'json'

        # https://github.com/cdunn/grape-jsonapi-resources
        formatter :json, Grape::Formatter::JSONAPIResources
        jsonapi_base_url "#{Rails.application.secrets.hostname}/api/v1"

        helpers do

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