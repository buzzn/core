require 'slim'
require 'slim/include'
require 'wicked_pdf'

require_relative '../services'

class Services::PdfHtmlGenerator

  def initialize(path = 'app/pdfs')
    @path = path
  end

  def resolve_template(name)
    file = File.join(@path, name)
    unless File.exists?(file)
      raise ArgumentError.new("#{name} not found in #{@path}")
    end
    source = File.read(file)
    basename = name.sub('.slim', '')
    template = Template.where(name: basename).order(version: :desc).limit(1).first
    if template.nil? || (File.mtime(file) > template.created_at && File.read(file) != template.source)
      template = Template.create(name: basename, source: source)
    end
    template
  end

  def generate_pdf(name_or_template, struct)
    WickedPdf.new(find_wkhtmltopdf_binary_path).pdf_from_string(render_html(name_or_template, struct), javascript_delay: 0, dpi: 75, extra: '--enable-forms')
  end

  def find_wkhtmltopdf_binary_path
    # don't take bundler version if one is available in the
    # path
    path = `PATH=$HOST_PATH && which wkhtmltopdf`.chomp
    path.present? ? path : nil
  end

  def render_html(name_or_template, struct)
    case name_or_template
    when String
      template = resolve_template(name_or_template)
    when Template
      template = name_or_template
    else
      raise "can not handle #{name_or_template.class}"
    end
    Slim::Engine.set_options include_dirs: [Dir.pwd, '.', 'app/pdfs/partials']
    Slim::Template.new { template.source }.render(struct)
  end

end
