# frozen_string_literal: true
require 'wine_bouncer/auth_strategies/protected'
module WineBouncer
  module AuthStrategies
    class Protectedbutswagger < WineBouncer::AuthStrategies::Protected
      def endpoint_protected?
        has_authorizations? && (api_context.env['REQUEST_PATH'].nil? || !api_context.env['REQUEST_PATH'].end_with?('swagger'))
      end
    end
  end
end
