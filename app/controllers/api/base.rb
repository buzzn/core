module API
  class Base < Grape::API
    include APIGuard
    mount API::V1::Base
  end
end