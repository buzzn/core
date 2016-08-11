module API
  class Base < Grape::API

    use ::WineBouncer::OAuth2

    mount API::V1::Base

  end
end
