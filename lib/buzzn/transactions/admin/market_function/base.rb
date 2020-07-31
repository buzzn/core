require_relative '../market_function'

module Transactions::Admin::MarketFunction
  class Base < Transactions::Base

    def check_relation(resource:, organization:, params:)
      if resource.function != params[:function]
        localpools = organization.groups_with_function[resource.function.to_sym]
        if !localpools.nil? && !localpools.empty?
          raise Buzzn::ValidationError.new({function: ["organization already serves as #{resource.function} for #{localpools.collect(&:id)}"]}, resource.object)
        end
      end
    end

  end
end
