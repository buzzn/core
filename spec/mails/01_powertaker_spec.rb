describe Mail::PowerTaker do

  entity(:org_example) do
    file = File.read 'spec/mails/01_powertaker_org.json'
    json = JSON.parse(file)
    Buzzn::Utils::Helpers.symbolize_keys_recursive(json)
  end

  entity(:person_example) do
    file = File.read 'spec/mails/01_powertaker_person.json'
    json = JSON.parse(file)
    Buzzn::Utils::Helpers.symbolize_keys_recursive(json)
  end

  [org_example, person_example].each do |example|
    subject { Mail::PowerTaker.new(example) }

    it 'renders text' do
      text = subject.to_text
      expect(text.length).to be > 0
    end

    it 'renders html', skip: true do
      html = subject.to_html
      expect(html.length).to be > 0
    end
  end

end
