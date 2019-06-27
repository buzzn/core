FactoryGirl.define do
  factory :comment do
    content { FFaker::DizzleIpsum.paragraph }
    author  { FFaker::NameDE.first_name }
  end
end
