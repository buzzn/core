class Broker < ActiveRecord::Base

  self.table_name = :brokers

  attr_encrypted :provider_password, :charset => 'UTF-8', :key => Rails.application.secrets.attr_encrypted_key

  belongs_to :resource, polymorphic: true

  validates :provider_login, presence: true
  validates :provider_password, presence: true

  validates :resource_id, presence: true
  validates :resource_type, presence: true

  scope :by_data_source, -> (data_source) do
    where(type: "#{data_source.class::NAME.to_s.camelize}Broker")
  end

  def two_way_meter?
    two_way_meter = self.resource.is_a?(Meter) && self.resource.registers.size > 1
  end

  private

  def self.do_get(mode, resource)
    # we have unique index on these three attributes
    result = where(mode: mode, resource_type: resource.class,
                   resource_id: resource.id).first
    if result.nil?
      raise ActiveRecord::NotFound.new
    end
    result
  end
end
