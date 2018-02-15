describe Buzzn::Pdfs::LSN_A01 do

  entity(:contractor) { create(:organization, :with_address, phone: '030-1237089432', fax: '030-1237089433') }
  entity(:person) { create(:person) }
  entity(:contract) do
    pool = create(:localpool, :with_address, owner: contractor)
    customer = create(:person, :with_bank_account, :with_address, phone: '089-234432')
    contract = create(:contract, :localpool_powertaker, localpool: pool, customer: customer)
    contract.customer_bank_account = contract.customer.bank_accounts.first
    contract.market_location.register.update(metering_point_id: 'DE17995926438168678487098331001')
    contract
  end

  let(:lsn_a01) { Buzzn::Pdfs::LSN_A01.new(contract) }

  xit 'renders html' do
    # we have a hardcoded date which needs to match
    Timecop.travel(Time.local(2016, 7, 2, 10, 5, 0)) do
      html = lsn_a01.to_html
      print_html(Buzzn::Pdfs::LSN_A01::TEMPLATE, html)
      expect(html).to eq File.read(__FILE__.sub(/rb$/, 'html'))
    end
  end

  xit 'generates pdf' do
    pdf = lsn_a01.to_pdf
    print_pdf(Buzzn::Pdfs::LSN_A01::TEMPLATE, pdf)
    expect(pdf).to start_with '%PDF-1.4'
  end

  context Buzzn::Pdfs::LSN_A01::ContractDecorator do

    it 'converts move_in to ja/nein' do
      begin
        expect(lsn_a01.power_taker.move_in).to eq 'nein'
        contract.update(move_in: true)
        expect(lsn_a01.power_taker.move_in).to eq 'ja'
      ensure
        contract.update(move_in: false)
      end
    end

    it 'addressing organization' do
      expect(lsn_a01.addressing).to eq 'Sehr geehrte Damen und Herren'
    end

    it 'addressing person (no prefix)' do
      begin
        person.update(prefix: nil, title: nil)
        contract.contractor = person
        expect(lsn_a01.addressing).to eq "Hallo  #{person.name}"
        contract.contractor.title = 'Dr'
        expect(lsn_a01.addressing).to eq "Hallo Dr #{person.name}"
      ensure
        contract.contractor = contractor
      end
    end

    it 'addressing woman' do
      begin
        person.update(prefix: 'female', title: nil)
        contract.contractor = person
        expect(lsn_a01.addressing).to eq "Sehr geehrte Frau  #{person.name}"
        contract.contractor.title = 'Dr'
        expect(lsn_a01.addressing).to eq "Sehr geehrte Frau Dr #{person.name}"
      ensure
        contract.contractor = contractor
      end
    end

    it 'addressing man' do
      begin
        person.update(prefix: 'male', title: nil)
        contract.contractor = person
        expect(lsn_a01.addressing).to eq "Sehr geehrter Herr  #{person.name}"
        contract.contractor.title = 'Dr'
        expect(lsn_a01.addressing).to eq "Sehr geehrter Herr Dr #{person.name}"
      ensure
        contract.contractor = contractor
      end
    end
  end
end
