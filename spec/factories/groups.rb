FactoryGirl.define do
  factory :localpool, class: 'Group::Localpool' do
    sequence(:name)        { |i| "Localpool #{i}" }
    description { |attrs| "#{attrs[:name]} description" }
  end
end