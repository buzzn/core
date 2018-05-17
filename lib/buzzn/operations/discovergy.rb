require_relative '../operations'

class Operations::Discovergy

  include Dry::Transaction::Operation
  include Import['services.datasource.discovergy.meters']

  def call(resource:, **)
    meter = resource.object
    if meter.discovergy? && !meters.connected?(meter)
      raise Buzzn::ValidationError.new(datasource: 'meter nust be connected with discovergy')
    end
    true
  end

end
