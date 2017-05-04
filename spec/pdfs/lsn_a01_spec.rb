describe Buzzn::Pdfs::LSN_A01 do

  subject { Buzzn::Pdfs::LSN_A01.new(Fabricate(:localpool_power_taker_contract)) }

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
end
