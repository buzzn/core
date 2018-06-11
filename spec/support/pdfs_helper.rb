require 'slim'

Slim::Engine.options[:pretty] = true
module PdfsHelper

  def print_html(name, content)
    FileUtils.mkdir_p('tmp/pdfs')
    file = "tmp/pdfs/#{name.sub('slim', 'html')}"
    root = File.expand_path('.') + '/'
    content.gsub!(root, '')
    File.open(file, 'wb') do |f|
      f.print(content)
    end
    logger.debug("dumped #{file}" )
    content
  end

  def print_pdf(name, content)
    FileUtils.mkdir_p('tmp/pdfs')
    file = "tmp/pdfs/#{name.sub('slim', 'pdf')}"
    File.open(file, 'wb') do |f|
      f.print(content)
    end
    logger.debug("dumped #{file}")
  end

  private

  def logger
    @logger ||= Buzzn::Logger.new(self)
  end

end
