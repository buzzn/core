describe Pdf::MeteringPointOperator do

  before(:all) do
    Kernel.srand 0
  end

  entity!(:person) { organization.contact }

  entity(:contract) { create(:contract, :metering_point_operator, localpool: localpool, contract_number: 90001) }

  entity(:localpool) { create(:group, :localpool, owner: organization) }
  entity(:organization) { create(:organization, :other, :with_address, :with_legal_representation, name: 'some-orga-name') }

  let(:name) { subject.send(:template_name) }
  subject { Pdf::MeteringPointOperator.new(contract) }

  context 'person customer' do
    before { localpool.owner = person }

    it 'renders html' do
      html = subject.to_html
      print_html(name, html)
      expect(html).to eq File.read(__FILE__.sub(/.rb$/, '_person.html'))
    end
  end

  context 'organization customer' do
    before { localpool.owner = organization }

    it 'renders html' do
      html = subject.to_html
      print_html(name, html)
      expect(html).to eq File.read(__FILE__.sub(/.rb$/, '_organization.html'))
    end
  end

  it 'generates pdf', slow: true do
    pdf = subject.to_pdf
    print_pdf(name, pdf)
    expect(pdf).to start_with '%PDF-1.4'
  end
end
