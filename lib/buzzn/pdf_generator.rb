module Buzzn
  class PdfGenerator < Buzzn::Services::PdfGenerator::Html
    include Import.reader['service.pdf_generator']

    def template
      self.class.const_get('TEMPLATE')
    rescue
      raise 'need constant TEMPLATE with file name in sub-class'
    end
    private :template

    def to_html
      pdf_generator.render_html(template, self)
    end

    def to_pdf
      pdf_generator.generate_from_html(template, self)
    end
  end
end
