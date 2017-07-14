describe Buzzn::Services::PdfHtmlGenerator do

  class With < Buzzn::Services::PdfHtmlGenerator::Html
    include Import.kwargs['service.pdf_html_generator']

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

  let(:this) { File.expand_path("..", __FILE__) }
  subject { Buzzn::Services::PdfHtmlGenerator.new(this) }

  it 'fails on wrong templates path' do
    expect { Buzzn::Services::PdfHtmlGenerator.new('something') }.to raise_error ArgumentError
    expect { Buzzn::Services::PdfHtmlGenerator.new(__FILE__) }.to raise_error ArgumentError
    expect do
      Dir.chdir(this) do
        # passing in nil means the auto_inject does its job
        Buzzn::Services::PdfHtmlGenerator.new('app/templates')
      end
    end.to raise_error ArgumentError
  end

  it 'generates plain html' do
    html = subject.render_html('simple.slim', Buzzn::Services::PdfHtmlGenerator::Html.new)
    expect(html).to eq "<!DOCTYPE html>\n<html>\n  <head>\n    <title>be happy</title>\n  </head>\n</html>"
  end

  it 'renders html - simple' do
    html = subject.render_html('with_parameters.slim', Buzzn::Services::PdfHtmlGenerator::Html.new)
    expect(html).to eq "<!DOCTYPE html>\n<html>\n  <head>\n    <title>be happy __when__</title>\n  </head>\n  <body>\n    <h1>\n      __time.today__\n    </h1>\n  </body>\n</html>"
  end

  it 'renders html' do
    html = subject.render_html('with_parameters.slim', With.new)
    expect(html).to eq "<!DOCTYPE html>\n<html>\n  <head>\n    <title>be happy all the time</title>\n  </head>\n  <body>\n    <h1>\n      1111-11-11\n    </h1>\n  </body>\n</html>"
  end

  it 'generates pdf' do
    pdf = subject.generate_pdf('with_parameters.slim', With.new(when: 'forever', time: Date))
    expect(pdf).to start_with '%PDF-1.4'
  end
end
