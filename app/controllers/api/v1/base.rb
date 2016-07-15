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
        hide_format: true
      )
    end
  end
end
