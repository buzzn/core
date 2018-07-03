require 'slim'

require_relative '../services'

class Services::MailGenerator

  def initialize(path = 'app/mails')
    @path = path
  end

  def resolve_template(name, extension, template_engine)
    filename = "#{name}.#{extension}.#{template_engine}"
    file = File.join(@path, filename)
    unless File.exist?(file)
      raise ArgumentError.new("#{filename} not found in #{@path}")
    end
    source = File.read(file)
    source
  end

  def render_text(name, struct)
    source = resolve_template(name, 'text', 'erb')
    ERB.new(source).result(struct.instance_eval { binding })
  end

  def render_html(name, struct)
    source = resolve_template(name, 'html', 'slim')
    Slim::Template.new { source }.render(struct)
  end

end
