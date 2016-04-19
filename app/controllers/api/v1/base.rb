require "grape-swagger"

module API
  module V1
    class Base < Grape::API
      mount API::V1::Auth
      mount API::V1::AccessTokens
      mount API::V1::Users
      mount API::V1::Profiles
      mount API::V1::MeteringPoints
      mount API::V1::Readings
      mount API::V1::Aggregate
      mount API::V1::Groups
      mount API::V1::Devices

      add_swagger_documentation(
        api_version: "v1",
        hide_documentation_path: true,
        mount_path: "/api/v1/swagger",
        hide_format: true
      )
    end
  end
end
