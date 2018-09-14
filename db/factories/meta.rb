FactoryGirl.define do
  factory :meta, class: 'Register::Meta' do

    name '1.OG links vorne'
    label                 Register::Meta.labels[:consumption]
    observer_enabled false
    observer_offline_monitoring false

    # This register is publicly connected. Only those have a metering point id
    trait :grid_connected do
      # TODO needs to move into Meter
      #metering_point_id # uses sequence
    end

    trait :grid_consumption do
      grid_connected
      label Register::Meta.labels[:grid_consumption]
    end

    trait :grid_feeding do
      grid_connected
      label Register::Meta.labels[:grid_feeding]
    end

    trait :production_bhkw do
      label Register::Meta.labels[:production_chp]
    end

    trait :production_pv do
      label Register::Meta.labels[:production_pv]
    end

    trait :production_water do
      label Register::Meta.labels[:production_water]
    end

    trait :production_wind do
      label Register::Meta.labels[:production_wind]
    end

    trait :consumption do
      label Register::Meta.labels[:consumption]
    end

    trait :consumption_common do
      label Register::Meta.labels[:consumption_common]
    end
  end
end
