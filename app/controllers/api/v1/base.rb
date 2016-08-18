require "grape-swagger"

module API
  module V1
    class Base < Grape::API
      def self.join(attributes, sep = ', ')
          attributes.collect do |a|
            case a
            when Hash
              a.collect do |k,v|
                "#{k}:#{v.join(sep)}"
              end
            else
              a
            end
          end.flatten.join(sep)
        end

      mount API::V1::Auth
      mount API::V1::AccessTokens
      mount API::V1::Users
      mount API::V1::Profiles
      mount API::V1::Meters
      mount API::V1::MeteringPoints
      mount API::V1::Readings
      mount API::V1::Aggregates
      mount API::V1::Groups
      mount API::V1::Devices
      mount API::V1::Contracts
      mount API::V1::Comments
      mount API::V1::Organizations

      add_swagger_documentation(
        api_version: "v1",
        hide_documentation_path: true,
        mount_path: "/api/v1/swagger",
        hide_format: true,
        security_definitions: {
          # those oauth2 keys need to match config/initializers/grape-swagger.rb
          swagger_ui: {
            type: 'oauth2',
            flow: 'implicit',
            authorizationUrl: Rails.application.secrets.hostname + '/oauth/authorize',
            scopes: Hash[Doorkeeper.configuration.scopes.collect do |scope|
                           [ scope, I18n.t("doorkeeper.scopes.#{scope}") ]
                         end]
          },
          third_party: {
            type: 'oauth2',
            flow: 'accessCode',
            authorizationUrl: Rails.application.secrets.hostname + '/oauth/authorize',
            tokenUrl: Rails.application.secrets.hostname + '/oauth/token',
            scopes: Hash[Doorkeeper.configuration.scopes.select{|s| s.to_sym != :smartmeter}.collect do |scope|
                           [ scope, I18n.t("doorkeeper.scopes.#{scope}") ]
                         end]
          },
          smartmeter: {
            type: 'oauth2',
            flow: 'password',
            tokenUrl: Rails.application.secrets.hostname + '/oauth/token',
            scopes: { smartmeter: I18n.t("doorkeeper.scopes.smartmeter") }
          },
          apiKey: {
            type: "apiKey",
            in: "header",
            name: "Authorization"
          }
        }
      )
    end
  end
end
