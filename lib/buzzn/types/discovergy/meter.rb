require_relative 'base'

class Types::Discovergy::Meter < Types::Discovergy::Base
  extend Dry::Initializer

  option :meter

  def to_query
    {meterId: meter.broker.external_id}.merge(attributes).compact
  end

  protected

  def attributes
    self.class.dry_initializer.public_attributes(self).except(:meter)
  end
end
