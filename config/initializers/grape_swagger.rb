GrapeSwaggerRails.options.url = "/api/v1/swagger.json"

GrapeSwaggerRails.options.app_name  = "buzzn api"
GrapeSwaggerRails.options.app_url   = Rails.application.secrets.hostname

GrapeSwaggerRails.options.api_auth     = 'bearer' # Or 'bearer' for OAuth
GrapeSwaggerRails.options.api_key_name = 'Authorization'
GrapeSwaggerRails.options.api_key_type = 'header'

# GrapeSwaggerRails.options.api_key_name = 'access_token'
# GrapeSwaggerRails.options.api_key_type = 'query'