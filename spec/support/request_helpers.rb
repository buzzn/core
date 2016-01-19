module Requests
  module JsonHelpers

    def json
      JSON.parse(response.body)
    end

    def request_headers
      return {
        "Accept" => "application/json",
        "Content-Type" => "application/json"
      }
    end

  end
end