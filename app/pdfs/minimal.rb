require 'buzzn/pdf_generator'

module Buzzn::Pdfs
  class Minimal < Buzzn::PdfGenerator

    def initialize(template = nil, **kwargs)
      super(kwargs)
      @template = template.sub('app/pdfs/', '') if template
    end

    protected

    def template
      @template || super
    end

    def build_struct
      {}
    end

  end
end
