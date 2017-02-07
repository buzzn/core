class MySmartGridBroker < Broker

  validates :provider_login, presence: true
  validates :provider_password, presence: true

  validates :resource_id, presence: true
  validates :resource_type, inclusion:{ in: [Meter.to_s] }
end

