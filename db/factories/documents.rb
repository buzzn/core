FactoryGirl.define do

  factory :document, class: 'Document' do

    data { Random.new.bytes(1024) }
    filename 'random.bin'

    trait :pdf do
      data { File.read('spec/data/' + build(:file, :pdf)[:file]) }
      filename { build(:file, :pdf)[:file] }
    end
  end

  factory :contract_document, class: 'ContractDocument' do

    trait :with_document do
      before(:create) do |contract_document, _evaluator|
        contract_document.document = [build(:document)]
      end
    end

    trait :with_contract do
      before(:create) do |contract_document, _evaluator|
        contract_document.contract = [build(:contract)]
      end
    end
  end
end
