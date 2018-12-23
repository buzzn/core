require_relative '../../reading'
require_relative '../../../../schemas/transactions/admin/reading/request'

module Transactions::Admin::Reading::Request

class Transactions::Admin::Reading::Request::Base < Transactions::Base

  include Import['services.reading_service']

  def schema
    Schemas::Transactions::Admin::Reading::Request
  end

  def allowed_roles(permission_context:)
    permission_context.readings.create
  end

  def check_resource(resource:, **)
    unless resource.is_a? Register::RealResource
      raise Buzzn::ValidationError.new('not a valid resource')
    end
  end

  def fetch_reading(resource:, params:, set_create:, **)
    time = params[:date].to_time
    readings = reading_service.get(resource.object, time, :precision => 2.days, fetch: false, create: set_create)
    # there are no readings, so we can actually request one
    unless readings.nil?
      raise Buzzn::ValidationError.new(register: {reason: 'readings are already present', readings: readings.collect { |x| x.id }})
    end
    readings = reading_service.get(resource.object, time, :precision => 2.days, fetch: true, create: set_create)
    if readings.nil?
      raise Buzzn::RemoteNotFound.new(register: {reason: 'reading could not be fetched'})
    end
    readings.first
  end

end
end
