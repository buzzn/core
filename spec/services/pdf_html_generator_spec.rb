describe Services::PdfHtmlGenerator do

  class Empty < Pdf::Generator::PdfStruct
  end

  class With < Pdf::Generator::PdfStruct

    def initialize(data = {})
      @data = data
    end

    def when
      @data[:when] || 'all the time'
    end

    def time
      @data[:time] || begin
                        o = Object
                        def o.today; '1111-11-11';end
                        o
                      end
    end

  end

  let(:this) { File.expand_path('../pdfs', __FILE__) }
  subject { Services::PdfHtmlGenerator.new(this) }

  it 'renders html simple' do
    html = subject.render_html('minimal.slim', Empty.new)
    expect(html).to eq "<!DOCTYPE html>\n<html>\n  <head>\n    <title>be happy</title>\n  </head>\n</html>"
  end

  it 'renders html with empty parameters' do
    html = subject.render_html('01_messvertrag.slim', Empty.new)
    expect(html).to eq "<!DOCTYPE html>\n<html>\n  <head>\n    <title>be happy __when__</title>\n  </head>\n  <body>\n    <h1>\n      __time.today__\n    </h1>\n  </body>\n</html>"
  end

  it 'renders html' do
    html = subject.render_html('01_messvertrag.slim', With.new)
    expect(html).to eq "<!DOCTYPE html>\n<html>\n  <head>\n    <title>be happy all the time</title>\n  </head>\n  <body>\n    <h1>\n      1111-11-11\n    </h1>\n  </body>\n</html>"
  end

  it 'generates pdf', slow: true do
    pdf = subject.generate_pdf('01_messvertrag.slim', With.new(when: 'forever', time: Date))
    expect(pdf).to start_with '%PDF-1.4'
  end
end
