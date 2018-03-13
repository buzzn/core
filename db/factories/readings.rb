FactoryGirl.define do
  factory :reading, class: 'Reading::Single' do
    register    { FactoryGirl.create(:register, :input) }
    date        Date.parse('2017-09-28')
    raw_value   1_234
    value       { raw_value }
    unit        :watt_hour
    reason      :device_setup
    read_by     :buzzn
    quality     :read_out
    source      :smart
    status      :z86
    comment     'Generic reading'

    trait :setup do
      reason    :device_setup
      comment   'Ablesung bei Einbau'
    end

    trait :regular do
      reason    :regular_reading
      comment   'Turnusablesung'
    end

    trait :contract_change do
      read_by   :power_taker
      reason    :contract_change
      comment   'Versorgerwechsel'
    end
  end
end
