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

  entity(:this) { File.expand_path('../pdfs', __FILE__) }
  entity(:generator) { Services::PdfHtmlGenerator.new(this) }

  it 'renders html simple' do
    html = generator.render_html('minimal.slim', Empty.new)
    expect(html).to eq "<!DOCTYPE html>\n<html>\n  <head>\n    <title>be happy</title>\n  </head>\n</html>"
  end

  it 'renders html with empty parameters' do
    html = generator.render_html('01_messvertrag.slim', Empty.new)
    expect(html).to eq "<!DOCTYPE html>\n<html>\n  <head>\n    <title>be happy __when__</title>\n  </head>\n  <body>\n    <h1>\n      __time.today__\n    </h1>\n  </body>\n</html>"
  end

  it 'renders html' do
    html = generator.render_html('01_messvertrag.slim', With.new)
    expect(html).to eq "<!DOCTYPE html>\n<html>\n  <head>\n    <title>be happy all the time</title>\n  </head>\n  <body>\n    <h1>\n      1111-11-11\n    </h1>\n  </body>\n</html>"
  end

  it 'generates pdf', slow: true do
    pdf = generator.generate_pdf('01_messvertrag.slim', With.new(when: 'forever', time: Date))
    expect(pdf).to start_with '%PDF-1.4'
  end

  context 'resolve template' do

    entity(:minimal) { File.join(this, 'minimal.slim') }
    entity!(:old) { generator.resolve_template('minimal.slim') }
    entity!(:before) do
      sleep 1;
      FileUtils.touch(minimal)
    end

    it { expect(old).to eq generator.resolve_template('minimal.slim') }

    context 'new template' do
      entity!(:before2) do
        generator.instance_variable_set(:@path, 'tmp/pdfs')
        FileUtils.cp(File.join(this, 'minimal2.slim'), 'tmp/pdfs/minimal.slim')
      end
      entity(:new) { generator.resolve_template('minimal.slim') }

      it { expect(old.name).to eq new.name }

      it { expect(old.version + 1).to eq new.version }

      it { expect(old.source).not_to eq new.source }
    end
  end
end
