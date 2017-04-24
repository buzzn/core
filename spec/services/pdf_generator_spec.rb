describe Buzzn::Services::PdfGenerator do

  let(:this) { File.expand_path("..", __FILE__) }
  subject { Buzzn::Services::PdfGenerator.new(this) }

  it 'fails on wrong templates path' do
    expect { Buzzn::Services::PdfGenerator.new('something') }.to raise_error ArgumentError
    expect { Buzzn::Services::PdfGenerator.new(__FILE__) }.to raise_error ArgumentError
    expect do
      Dir.chdir(this) do
        # passing in nil means the auto_inject does its job
        Buzzn::Services::PdfGenerator.new('app/templates')
      end
    end.to raise_error ArgumentError
  end

  it 'generates plain html' do
    html = subject.generate_html('simple.slim', {})
    expect(html).to eq '<!DOCTYPE html><html><head><title>be happy</title></head></html>'
  end

  it 'generates html with parameter' do
    html = subject.generate_html('with_parameters.slim', {when: 'forever', time: Date})
    expect(html).to eq "<!DOCTYPE html><html><head><title>be happy forever</title></head><body><h1>#{Date.today}</h1></body></html>"
  end

  class With < Buzzn::Services::PdfGenerator::Html
    include Import.args['service.pdf_generator']

    def initialize(pdf_generator)
      super(pdf_generator.resolve_template('with_parameters.slim'))
    end

    def when
      'all the time'
    end

    def time
      o = Object
      def o.today; '1111-11-11';end
      o
    end
  end

  it 'renders html' do
    html = subject.render_html(With.new(subject))
    expect(html).to eq "<!DOCTYPE html><html><head><title>be happy all the time</title></head><body><h1>1111-11-11</h1></body></html>"
  end

  it 'generates pdf from html' do
    pdf = subject.generate_from_html(With.new(subject))
    expect(pdf).to start_with '%PDF-1.4'
  end

  it 'generates pdf' do
    pdf = subject.generate('with_parameters.slim',{when: 'forever', time: Date})
    expect(pdf).to start_with '%PDF-1.4'
  end
end
