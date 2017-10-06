FactoryGirl.define do
  factory :localpool, class: 'Group::Localpool' do
    name        { generate(:localpool_name) }
    description { |attrs| "#{attrs[:name]} description" }

    trait :people_power do
      name "People Power Group"
      description "Power to the people!"
      website "www.peoplepower.de"
    end
  end
end