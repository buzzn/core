require_relative 'pdf_generator'

module Pdf
  class Minimal < Generator

    def initialize(template = nil, **kwargs)
      super(kwargs)
      @template = template.sub('app/pdfs/', '') if template
    end

    protected

    def template
      @template || super
    end

    def build_struct
      {
        name: 'me and the corner'
      }
    end

  end
end
