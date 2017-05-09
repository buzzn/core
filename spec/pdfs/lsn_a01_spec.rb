describe Buzzn::Pdfs::LSN_A01 do

  entity(:contractor) { Fabricate(:hell_und_warm) }
  entity(:user) { Fabricate(:user) }
  entity(:contract) do
    contract = Fabricate(:lptc_mabe)
    contract.customer = Fabricate(:mustafa)
    contract.customer.profile.update(phone: '089-234432')
    contract.customer_bank_account = Fabricate(:bank_account_mustermann)
    contract.contractor = contractor
    contract.contractor.update(phone: '030-1237089432', fax: '030-1237089433')
    Fabricate(:justus).add_role(:manager, contract.contractor)
    contract.contractor.address = Fabricate(:address)
    contract.customer.address = Fabricate(:address)
    contract.register = Fabricate(:easymeter_60404849).registers.first
    contract.register.update(uid: 'DE17995926438168678487098331001') 
    contract.register.group = Fabricate(:localpool_sulz)
    contract
  end

  subject { Buzzn::Pdfs::LSN_A01.new(contract) }

  it 'renders html' do
    html = subject.to_html
    print_html(Buzzn::Pdfs::LSN_A01::TEMPLATE, html)
    expect(html).to eq File.read(__FILE__.sub(/rb$/, 'html'))
  end

  it 'generates pdf' do
    pdf = subject.to_pdf
    print_pdf(Buzzn::Pdfs::LSN_A01::TEMPLATE, pdf)
    expect(pdf).to start_with '%PDF-1.4'
  end

  context Buzzn::Pdfs::LSN_A01::ContractDecorator do

    it 'converts move_in to ja/nein' do
      begin
        expect(subject.power_taker.move_in).to eq 'nein'
        contract.update(move_in: true)
        expect(subject.power_taker.move_in).to eq 'ja'
      ensure
        contract.update(move_in: false)
      end
    end

    it 'addressing organization' do
      expect(subject.addressing).to eq 'Sehr geehrte Damen und Herren'
    end

    it 'addressing person (no gender)' do
      begin
        user.profile.update(gender: nil, title: nil)
        contract.contractor = user
        expect(subject.addressing).to eq "Hallo  #{user.name}"
        contract.contractor.profile.title = 'Dr'
        expect(subject.addressing).to eq "Hallo Dr #{user.name}"
      ensure
        contract.contractor = contractor
      end
    end

    it 'addressing woman' do
      begin
        user.profile.update(gender: 'female', title: nil)
        contract.contractor = user
        expect(subject.addressing).to eq "Sehr geehrte Frau  #{user.name}"
        contract.contractor.profile.title = 'Dr'
        expect(subject.addressing).to eq "Sehr geehrte Frau Dr #{user.name}"
      ensure
        contract.contractor = contractor
      end
    end

    it 'addressing man' do
      begin
        user.profile.update(gender: 'male', title: nil)
        contract.contractor = user
        expect(subject.addressing).to eq "Sehr geehrter Herr  #{user.name}"
        contract.contractor.profile.title = 'Dr'
        expect(subject.addressing).to eq "Sehr geehrter Herr Dr #{user.name}"
      ensure
        contract.contractor = contractor
      end
    end
  end
end
