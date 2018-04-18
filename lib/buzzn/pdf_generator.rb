require 'ostruct'

require_relative 'builders/struct_builder'
require_relative 'services/pdf_html_generator'

module Buzzn
  class PdfGenerator #< ::Services::PdfHtmlGenerator::Html

    class PdfStruct < OpenStruct

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

      def method_missing(method, *args)
        if respond_to?(method)
          super
        else
          Missing.new(method)
        end
      end

    end

    include Import.reader['services.pdf_html_generator']

    def initialize(*)
      @builder = Builders::StructBuilder.new(PdfStruct)
    end

    def to_html
      pdf_html_generator.render_html(template, struct)
    end

    def to_pdf
      pdf_html_generator.generate_pdf(template, struct)
    end

    def create_pdf_document
      PdfDocument.transaction do
        yield(PdfDocument.create(template: template,
                                 json: @table.to_json,
                                 document: Document.store(to_pdf)))
      end
    end

    protected

    def build_struct
      raise "not implemented #{self.class}"
    end

    def template
      method(:initialize).source_location[0].sub(/rb$/, 'slim').sub(/.*\//, '')
    end

    private

    def struct
      @struct ||= @builder.build(build_struct)
    end

  end
end
