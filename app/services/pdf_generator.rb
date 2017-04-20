class Buzzn::Services::PdfGenerator
  include Import.args[path: 'config.templates_path']
  
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

  def initialize(templates = nil, options = {})
    @path = (templates || 'app/templates').to_s
    @options = options || {}
  end

  def generate_html(name, attributes, options = {})
    file = File.join(@path, name)
    raise "#{name} not found in #{@path}" unless File.exists?(file)
    Html.new(file, @options.merge(options), attributes).render
  end

  def generate(name, attributes)
    WickedPdf.new.pdf_from_string(generate_html(name, attributes))
  end
end
