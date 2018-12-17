require_relative '../reading'
require_relative '../../../schemas/transactions/admin/reading/request'

class Transactions::Admin::Reading::Request < Transactions::Base

  include Import['services.reading_service']

  validate :schema
  authorize :allowed_roles
  tee :check_resource
  add :fetch_reading
  map :wrap_up

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

  def fetch_reading(resource:, params:, **)
    time = params[:date].to_time
    readings = reading_service.get(resource.object, time, :precision => 1.minutes, fetch: false)
    # there are no readings, so we can actually request one
    unless readings.nil?
      raise Buzzn::StateError.new(register: {reason: 'readings are already present', readings: readings.collect { |x| x.id }})
    end
    readings = reading_service.get(resource.object, time, :precision => 1.minutes, fetch: true)
    if readings.nil?
      raise Buzzn::StateError.new(register: {reason: 'reading could not be fetched'})
    end
    readings.first
  end

  def wrap_up(params:, resource:, fetch_reading:, **)
    ReadingResource.new(fetch_reading)
  end

end
