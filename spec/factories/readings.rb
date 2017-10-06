FactoryGirl.define do
  factory :reading, class: 'Reading::Single' do
    register    { FactoryGirl.create(:register_input) }
    date        Date.parse("2017-09-28")
    raw_value   1_234
    value       1_234
    unit        Reading::Single.units[:watt_hour]
    reason      Reading::Single.reasons[:device_setup]
    read_by     Reading::Single.read_bys[:buzzn]
    quality     Reading::Single.qualities[:read_out]
    source      Reading::Single.sources[:smart]
    status      Reading::Single.statuses[:z86]
    comment     "Ablesung bei Einbau"
  end
end