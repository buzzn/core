require 'buzzn/resource/context'

module Buzzn::Resource

  class AllowAllContext < Context

    class AllPermission

      def retrieve(*)
        [Role::BUZZN_OPERATOR]
      end

      def method_missing(method, *)
        self
      end

    end

    def initialize
      super(Account::Base.first, [Role::BUZZN_OPERATOR], AllPermission.new)
    end

  end

end
