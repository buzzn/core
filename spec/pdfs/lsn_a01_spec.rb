Slim::Engine.options[:pretty] = true
describe Buzzn::Pdfs::LSN_A01 do

  subject { Buzzn::Pdfs::LSN_A01.new('asd') }

  it 'renders html' do
    html = subject.to_html
    File.open("tmp/pdfs/#{Buzzn::Pdfs::LSN_A01::TEMPLATE.sub('slim', 'html')}",
              'wb') do |f|
      f.print(html)
    end
    expect(html).to eq File.read(__FILE__.sub(/rb$/, 'html'))
  end

  it 'generates pdf' do
    pdf = subject.to_pdf
    File.open("tmp/pdfs/#{Buzzn::Pdfs::LSN_A01::TEMPLATE.sub('slim', 'pdf')}",
              'wb') do |f|
      f.print(pdf)
    end
    expect(pdf).to start_with '%PDF-1.4'
  end
end
