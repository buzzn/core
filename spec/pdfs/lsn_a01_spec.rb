require 'lsn_a01'
describe Buzzn::Pdfs::LSN_A01 do

  entity(:contractor) { Fabricate(:hell_und_warm_deprecated) }
  entity(:person) { Fabricate(:person) }
  entity(:contract) do
    contract = Fabricate(:lptc_mabe)
    contract.customer = Fabricate(:mustafa).person
    contract.customer.update(phone: '089-234432')
    contract.customer_bank_account = Fabricate(:bank_account_mustermann)
    contract.contractor = contractor
    contract.contractor.update(phone: '030-1237089432', fax: '030-1237089433',
                               contact: Fabricate(:justus).person)
    contract.contractor.address = Fabricate(:address)
    contract.customer.address = Fabricate(:address)
    contract.register = Fabricate(:easymeter_60404849).registers.first
    contract.register.meter.update(address: Fabricate(:address_sulz))
    contract.register.update(metering_point_id: 'DE17995926438168678487098331001')
    contract.register.group = Fabricate(:localpool_sulz)
    contract
  end

  subject { Buzzn::Pdfs::LSN_A01.new(contract) }

  it 'renders html' do
    # we have a hardcoded date which needs to match
    Timecop.travel(Time.local(2016, 7, 2, 10, 5, 0)) do
      html = subject.to_html
      print_html(Buzzn::Pdfs::LSN_A01::TEMPLATE, html)
      expect(html).to eq File.read(__FILE__.sub(/rb$/, 'html'))
    end
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

    it 'addressing person (no prefix)' do
      begin
        person.update(prefix: nil, title: nil)
        contract.contractor = person
        expect(subject.addressing).to eq "Hallo  #{person.name}"
        contract.contractor.title = 'Dr'
        expect(subject.addressing).to eq "Hallo Dr #{person.name}"
      ensure
        contract.contractor = contractor
      end
    end

    it 'addressing woman' do
      begin
        person.update(prefix: 'female', title: nil)
        contract.contractor = person
        expect(subject.addressing).to eq "Sehr geehrte Frau  #{person.name}"
        contract.contractor.title = 'Dr'
        expect(subject.addressing).to eq "Sehr geehrte Frau Dr #{person.name}"
      ensure
        contract.contractor = contractor
      end
    end

    it 'addressing man' do
      begin
        person.update(prefix: 'male', title: nil)
        contract.contractor = person
        expect(subject.addressing).to eq "Sehr geehrter Herr  #{person.name}"
        contract.contractor.title = 'Dr'
        expect(subject.addressing).to eq "Sehr geehrter Herr Dr #{person.name}"
      ensure
        contract.contractor = contractor
      end
    end
  end
end
