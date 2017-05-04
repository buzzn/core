Slim::Engine.options[:pretty] = true
module PdfsHelper
  def print_html(name, content)
    FileUtils.mkdir_p('tmp/pdfs')
    file = "tmp/pdfs/#{name.sub('slim', 'html')}"
    File.open(file, 'wb') do |f|
      f.print(content)
    end
    _log "dumped #{file}"
  end

  def print_pdf(name, content)
    FileUtils.mkdir_p('tmp/pdfs')
    file = "tmp/pdfs/#{name.sub('slim', 'pdf')}"
    File.open(file, 'wb') do |f|
      f.print(content)
    end
    _log "dumped #{file}"
  end

  private
  def _log(file)
    warn "  ------> #{file}"
  end
end
