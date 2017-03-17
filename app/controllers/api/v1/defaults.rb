require 'doorkeeper/grape/helpers'
require 'buzzn/guarded_crud'


module API
  module V1
    module Defaults
      
      extend ActiveSupport::Concern
      included do
        prefix "api"
        version "v1", using: :path
        format 'json'

        formatter :json, ->(object, env) do
          Buzzn::SerializableResource.new(object).to_json
        end

        jsonapi_base_url "#{Rails.application.secrets.hostname}/api/v1"

        helpers Doorkeeper::Grape::Helpers
        helpers Buzzn::Grape::Caching
        
        helpers do

          def current_user
            env['warden'].authenticate(scope: :user)
            if env['warden'].user
              return env['warden'].user
            end
            User.unguarded_retrieve(doorkeeper_token.resource_owner_id) if doorkeeper_token
          end

          def permitted_params
            @permitted_params ||= declared(params, include_missing: false)
          end

          def data_id
            permitted_params[:data][:id]
          end

          def data_id_array
            permitted_params[:data].collect{ |d| d[:id] }
          end

          def logger
            Rails.logger
          end

          def created_response(obj)
            if obj.persisted?
              header('Location', obj.id.to_s)
              status 201
            end
            obj
          end

          def deleted_response(obj)
            status 204
          end

          def paginated_response(objs)
            per_page     = permitted_params[:per_page]
            page         = permitted_params[:page]
            total_pages  = objs.page(page).per_page(per_page).total_pages
            paginate(render(objs, meta: { total_pages: total_pages }))
          end
        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          error_response(message: e.message, status: 404)
        end

        rescue_from Buzzn::DataSourceError do |e|
          error_response(message: e.message, status: 504)
        end

        rescue_from Buzzn::RecordNotFound do |e|
          error_response(message: e.message, status: 404)
        end

        rescue_from Buzzn::PermissionDenied do |e|
          error_response(status: 403)
        end

        class Max < Grape::Validations::Base
          def validate_param!(attr_name, params)
            unless params[attr_name] <= @option
              fail Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "must be at the smaller then #{@option}"
            end
          end
        end

        class ErrorResponse < Rack::Response

          def initialize(status = 500, headers = {})
            super([], status, headers)
            @errors = []
          end

          def add_general(title, detail)
              @errors << { "title": title,
                           "detail": detail }
          end

          def add(name, *messages)
            name = name.to_s
            if name.include? '.'
              name = name.sub(/\./, '[').sub(/\./, '][') + ']'
            end
            messages.each do |msg|
              @errors << { "source":
                             { "pointer": "/data/attributes/#{name}" },
                           "title": "Invalid Attribute",
                           "detail": "#{name} #{msg}" }
            end
          end

          def to_hash
            { errors: @errors }
          end

          def finish
            write to_hash.to_json
            super
          end
        end

        rescue_from Grape::Exceptions::ValidationErrors do |e|
          errors = ErrorResponse.new(422, { Grape::Http::Headers::CONTENT_TYPE => content_type })
          e.errors.each do |key, value|
            key.each_with_index do |k, i|
              errors.add(k, value[i])
            end
          end

          errors.finish
        end

        rescue_from ArgumentError do |e|
          errors = ErrorResponse.new(422, { Grape::Http::Headers::CONTENT_TYPE => content_type })
          puts e.backtrace.join("\n\t")
          errors.add_general('Argument Error', e.message)
          errors.finish
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          errors = ErrorResponse.new(422, { Grape::Http::Headers::CONTENT_TYPE => content_type })
          e.record.errors.messages.each do |attr, value|
            errors.add(attr, *value)
          end

          errors.finish
        end

        rescue_from Buzzn::ValidationError do |e|
          errors = ErrorResponse.new(422, { Grape::Http::Headers::CONTENT_TYPE => content_type })
          e.errors.each do |attr, value|
            errors.add(attr, *value)
          end

          errors.finish
        end

        rescue_from :all do |e|
          eclass = e.class.to_s
          if eclass.match('WineBouncer::Errors')
            title = e.response.name.to_s.split('_').collect{|s| s.capitalize}.join(' ')
            if e.response.name == :invalid_scope
              message = "Invalid scope. Allowed scopes are: #{e.response.instance_variable_get(:@scopes).join(', ')}"
            else
              message = e.to_s
            end
          end
          status = case
                   when eclass.match('OAuthUnauthorizedError')
                     401 # forbidden
                   when eclass.match('OAuthForbiddenError')
                     403 # no permissions
                   else
                     title = 'Internal Error'
                     message = e.message
                     (e.respond_to? :status) && e.status || 500
                   end
          opts = { errors: [ { title: title, detail: message } ] }
          unless Rails.env.production?
            opts.merge!({ meta: { trace: e.backtrace[0, 10] } })
          end
          Rack::Response.new(opts.to_json, status, { Grape::Http::Headers::CONTENT_TYPE => content_type }).finish
        end
      end
    end
  end
end
