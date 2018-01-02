module Buzzn
  class PdfGenerator < ::Services::PdfHtmlGenerator::Html
<<<<<<< HEAD
    include Import.reader['services.pdf_html_generator']
=======
    include Import.reader['service.pdf_html_generator']
>>>>>>> cleanup namespace setup

    def template
      self.class.const_get('TEMPLATE')
    rescue
      raise 'need constant TEMPLATE with file name in sub-class'
    end
    private :template

    def to_html
      pdf_html_generator.render_html(template, self)
    end

    def to_pdf
      pdf_html_generator.generate_pdf(template, self)
    end
  end
end
