class Broker::MySmartGrid < Broker::Base

  validates :provider_login, presence: true
  validates :provider_password, presence: true

  validates :resource_id, presence: true
  validates :resource_type, inclusion:{ in: [Meter::Base.to_s] }
end

