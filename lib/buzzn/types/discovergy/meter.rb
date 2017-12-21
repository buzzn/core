require_relative 'base'

class Types::Discovergy::Meter < Types::Discovergy::Base
  extend Dry::Initializer

  option :meter

  def to_query
    {meterId: meter_id}.merge(attributes).compact
  end

  protected

  def attributes
    self.class.dry_initializer.public_attributes(self).except(:meter)
  end

  private

  def meter_id
    case meter
    when Meter::Base
      meter.broker.external_id
    when OpenStruct
      "#{meter.type}_#{meter.serialNumber}"
    else
      raise "can not handle: #{meter}"
    end
  end
end
