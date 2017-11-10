FactoryGirl.define do
  factory :reading, class: 'Reading::Single' do
    register    { FactoryGirl.create(:register, :input) }
    date        Date.parse("2017-09-28")
    raw_value   1_234
    value       { raw_value }
    unit        Reading::Single.units[:watt_hour]
    reason      Reading::Single.reasons[:device_setup]
    read_by     Reading::Single.read_by[:buzzn]
    quality     Reading::Single.qualities[:read_out]
    source      Reading::Single.sources[:smart]
    status      Reading::Single.status[:z86]
    comment     'Generic reading'

    trait :setup do
      reason    Reading::Single.reasons[:device_setup]
      comment   'Ablesung bei Einbau'
    end

    trait :regular do
      reason    Reading::Single.reasons[:regular_reading]
      comment   'Turnusablesung'
    end

    trait :contract_change do
      read_by   Reading::Single.read_by[:power_taker]
      reason    Reading::Single.reasons[:contract_change]
      comment   'Versorgerwechsel'
    end
  end
end
