FactoryGirl.define do
  factory :localpool, class: 'Group::Localpool' do
    name        { generate(:localpool_name) }
    description { |attrs| "#{attrs[:name]} description" }
    owner       { FactoryGirl.create(:person) }
    trait :people_power do
      name "People Power Group"
      description "Power to the people!"
      website "www.peoplepower.de"
    end

    trait :hell_und_warm do
      name "hell & warm"
      description "Hell und Warm!"
      website "www.hellundwarm.de"
    end
  end
end