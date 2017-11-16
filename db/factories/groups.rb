FactoryGirl.define do
  factory :localpool, class: 'Group::Localpool' do

    transient do
      admins []
      tariffs_attrs []
      distribution_system_operator nil
      transmission_system_operator nil
      electricity_supplier nil
    end

    name        { generate(:localpool_name) }
    description { |attrs| "#{attrs[:name]} description" }
    owner       { FactoryGirl.create(:person) }
    address
    start_date  { Date.parse("2016-01-01") }

    trait :people_power do
      name "People Power Group"
      description "Power to the people!"
      # FIXME resurrect this once we have it used by the application
      #website "www.peoplepower.de"
    end

    after(:create) do |group, evaluator|
      group.owner.add_role(Role::GROUP_OWNER, group)
      evaluator.admins.each { |admin| admin.add_role(Role::GROUP_ADMIN, group) }
      evaluator.tariffs_attrs.each { |tariff_attrs| build(:tariff, tariff_attrs.merge(group: group)) }
      group.update(distribution_system_operator: evaluator.distribution_system_operator, transmission_system_operator: evaluator.transmission_system_operator, electricity_supplier: evaluator.electricity_supplier)
    end
  end
end
