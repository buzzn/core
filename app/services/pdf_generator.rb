class Buzzn::Services::PdfGenerator
  include Import.args[path: 'config.templates_path']
  
  class Html < OpenStruct

    def initialize(file, attributes = nil)
      @file = file
      super(attributes || {})
    end

    def render
      Slim::Template.new(@file).render(self)
    end
  end

  def initialize(templates = nil)
    @path = File.expand_path(templates || 'app/templates')
    
    unless File.exists?(@path)
      raise ArgumentError.new("#{@path} does not exist")
    end
    unless File.directory?(@path)
      raise ArgumentError.new("#{@path} is not a directory")
    end
  end

  def resolve_template(name)
    file = File.join(@path, name)
    unless File.exists?(file)
      raise ArgumentError.new("#{name} not found in #{@path}")
    end
    file
  end

  def generate_html(name, attributes)
    file = resolve_template(name)
    render_html(Html.new(file, attributes))
  end

  def render_html(html)
    html.render
  end

  def generate(name, attributes)
    WickedPdf.new.pdf_from_string(generate_html(name, attributes))
  end

  def generate_from_html(html)
    WickedPdf.new.pdf_from_string(render_html(html))
  end
end
