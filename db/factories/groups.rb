FactoryGirl.define do
  factory :localpool, class: 'Group::Localpool' do

    transient do
      admins []
    end

    name        { generate(:localpool_name) }
    description { |attrs| "#{attrs[:name]} description" }
    owner       { FactoryGirl.create(:person) }
    address

    trait :people_power do
      name "People Power Group"
      description "Power to the people!"
      website "www.peoplepower.de"
    end

    after(:create) do |group, evaluator|
      group.owner.add_role(Role::GROUP_OWNER, group)
      evaluator.admins.each { |admin| admin.add_role(Role::GROUP_ADMIN, group) }
    end
  end
end
