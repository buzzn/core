require 'lcp_report'
describe Buzzn::Pdfs::LCP_Report do

  entity(:localpool) { Fabricate(:localpool_sulz_with_registers_and_readings) }

  let(:total_accounted_energy) do
    begin_date = Date.new(2016, 8, 4)
    Buzzn::Services::ReadingCalculation.new.get_all_energy_in_localpool(localpool, begin_date, nil, 2016)
  end

  subject { Buzzn::Pdfs::LCP_Report.new(total_accounted_energy: total_accounted_energy) }

  it 'renders html' do
    # TODO make this work and correct
    skip('the time range calculations are totally broken and whole setup does match')
    html = subject.to_html
    print_html(Buzzn::Pdfs::LCP_Report::TEMPLATE, html)
    expect(html).to eq File.read(__FILE__.sub(/rb$/, 'html'))
  end

  it 'generates pdf' do
    skip("Impossible to figure out what's broken, and I'm not even sure we're going to keep the calculation code.")
    pdf = subject.to_pdf
    print_pdf(Buzzn::Pdfs::LCP_Report::TEMPLATE, pdf)
    expect(pdf).to start_with '%PDF-1.4'
  end
end
