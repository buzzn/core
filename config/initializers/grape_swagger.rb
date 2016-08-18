GrapeSwaggerRails.options.app_name      = "buzzn api"

GrapeSwaggerRails.options.app_url       = Rails.application.secrets.hostname
GrapeSwaggerRails.options.url           = "/api/v1/swagger"

begin
  swagger_ui = Doorkeeper::Application.where(name: 'Buzzn Swagger UI').first
  if swagger_ui
    GrapeSwaggerRails.options.oauth_client_id    = swagger_ui.uid
    GrapeSwaggerRails.options.oauth_redirect_uri = swagger_ui.redirect_uri
  end
rescue
  # ignore as rake tasks without database might run this initializer
end

GrapeSwaggerRails.options.hide_api_key_input = true
# GrapeSwaggerRails.options.api_auth      = 'bearer' # Or 'bearer' for OAuth
# GrapeSwaggerRails.options.api_key_name  = 'Authorization'
# GrapeSwaggerRails.options.api_key_type  = 'header'

# GrapeSwaggerRails.options.api_key_name = 'access_token'
# GrapeSwaggerRails.options.api_key_type = 'query'

# monkey patch to copy wine_bouncer scope config over to swagger json

module Grape
  class Endpoint
    alias :method_object_old :method_object
    def method_object(route, options, path)
      request_method, method = method_object_old(route, options, path)

      # look into wine_bouncer authorization options
      if auth = route.options[:authorizations]
        security = method[:security] || []
        auth.each do |k, scopes|
          list = []
          scopes.each do |scope|
            scope.each do |k,v|
              list << v.to_s
            end
          end
          # do not use false as scope as wine_bouncer uses it
          # skip if there is no-authorization
          unless list.delete('false')
            security << {"swagger_ui": list}
            method[:security] = security
            # adds api-key which is configured to use access-token as api-key
            security << { apiKey: [] }
          end
        end
      end

      [request_method, method]
    end
  end
end
