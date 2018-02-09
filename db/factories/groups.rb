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
    start_date  { Date.parse('2016-01-01') }

    after(:create) do |group, evaluator|
      person_for_role = group.owner.is_a?(Organization) ? group.owner.contact : group.owner
      person_for_role.add_role(Role::GROUP_OWNER, group)
      evaluator.admins.each { |admin| admin.add_role(Role::GROUP_ADMIN, group) }
      evaluator.tariffs_attrs.each { |tariff_attrs| create(:tariff, tariff_attrs.merge(group: group)) }
      group.update(distribution_system_operator: evaluator.distribution_system_operator, transmission_system_operator: evaluator.transmission_system_operator, electricity_supplier: evaluator.electricity_supplier)
    end
  end
end
