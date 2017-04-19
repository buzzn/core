class Buzzn::Pdf::Generator

  class Html < OpenStruct

    def initialize(file, options = {}, attributes = {})
      @file = file
      @options = options
      super(attributes)
    end

    def render
      Slim::Template.new(@file, @options).render(self)
    end
  end

  def initialize(templates = 'app/templates', options = {})
    @path = templates
    @options = options
  end

  def generate_html(name, attributes)
    file = File.join(@path, name)
    raise "#{name} not found in #{@path}" unless File.exists?(file)
    Html.new(file, @options, attributes).render
  end

  def generate(name, attributes)
    WickedPdf.new.pdf_from_string(generate_html(name, attributes))
  end
end
