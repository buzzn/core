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
    when Meter::Discovergy
      "VIRTUAL_#{meter.product_serialnumber}"
    when Meter::Base
      "EASYMETER_#{meter.product_serialnumber}"
    when OpenStruct
      "#{meter.type}_#{meter.serialNumber}"
    else
      raise "can not handle: #{meter}"
    end
  end

end
