class Buzzn::Services::PdfHtmlGenerator
  include Import.args[path: 'config.templates_path']

  class Missing

    def initialize(name)
      @name = name
    end

    def method_missing(method, *args)
      "__#{@name}.#{method}__"
    end

    def to_s
      "__#{@name}__"
    end
  end

  class Html

    def render(file)
      Slim::Template.new(file).render(self)
    end

    def method_missing(method, *args)
      Missing.new(method)
    end
  end

  def initialize(templates = nil)
    @path = File.expand_path(templates || 'app/pdfs')
    
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

  def generate_pdf(name, html)
    WickedPdf.new.pdf_from_string(render_html(name, html),
                                  footer: { left: 'Seite [page] von [topage]' })
  end

  def render_html(name, html)  
    file = resolve_template(name)
    html.render(file)
  end
end
