describe Pdf::MeteringPointOperatorContract, :pdfs_helper do

  before(:all) do
    Kernel.srand 0
  end

  entity!(:person) { organization.contact }

  entity(:contract) { create(:contract, :metering_point_operator, localpool: localpool, contract_number: 90001) }

  entity(:localpool) { create(:group, :localpool, :with_address, owner: organization) }
  entity(:organization) { create(:organization, :with_contact, :with_address, :with_legal_representation, name: 'some-orga-name') }

  let(:name) { subject.send(:template_name) }
  subject { Pdf::MeteringPointOperatorContract.new(contract) }

  context 'person customer' do
    before { localpool.owner = person }

    it 'renders html' do
      html = subject.to_html
      print_html(name, html)
    end
  end

  context 'organization customer' do
    before { localpool.owner = organization }

    it 'renders html' do
      html = subject.to_html
      print_html(name, html)
    end
  end

  it 'generates pdf', slow: true do
    pdf = subject.to_pdf
    print_pdf(name, pdf)
    expect(pdf).to start_with '%PDF-1.4'
  end
end
