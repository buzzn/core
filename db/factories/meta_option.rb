FactoryGirl.define do
  factory :meta_option, class: 'Register::MetaOption' do
    share_with_group      false
    share_publicly        false

    trait :private do

    end

    trait :public do
      share_with_group      true
      share_publicly        true
    end
  end
end
