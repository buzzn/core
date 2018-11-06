FactoryGirl.define do
  factory :website_form, class: 'WebsiteForm' do
    processed false
    form_name 'powertaker_v1'
    form_content '{ "key": "value" }'
  end
end
