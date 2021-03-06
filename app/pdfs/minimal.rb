require_relative 'generator'

module Pdf
  class Minimal < Generator

    def initialize(template = nil, root: nil, **kwargs)
      super(root, kwargs)
      @template = template.sub('app/pdfs/', '') if template
    end

    def template
      @template || super
    end

    protected

    def build_struct
      {
        name: 'me and the corner'
      }
    end

  end
end
