class MySmartGridBroker < Broker

  belongs_to :meter

  validates :external_id, presence: true
  validates :provider_login, presence: true
  validates :provider_password, presence: true

  validates :meter_id, presence: true
end

