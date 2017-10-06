FactoryGirl.define do
  factory :localpool, class: 'Group::Localpool' do
    name        { generate(:localpool_name) }
    description { |attrs| "#{attrs[:name]} description" }
  end
end