require 'ostruct'

require 'buzzn/builders/struct_builder'

module Pdf
  class Generator

    class PdfStruct < OpenStruct

      class Missing

        def initialize(name)
          @name = name
        end

        def method_missing(method, *args, &block)
          "__#{@name}.#{method}__" || super # hack to satisfy rubocop
        end

        def respond_to_missing?(*)
          true
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

      def respond_to_missing?(*)
        super
      end

    end

    include Import.reader['services.pdf_html_generator']

    def initialize(root_object, **)
      @logger = Buzzn::Logger.new(self)
      @root = root_object
      @builder = Builders::StructBuilder.new(PdfStruct)
    end

    def to_html
      pdf_html_generator.render_html(template, struct)
    end

    def to_pdf
      time = Buzzn::Utils::Chronos.now.to_f
      pdf = pdf_html_generator.generate_pdf(template, struct)
      @logger.info{ "#{Buzzn::Utils::Chronos.now.to_f - time} seconds" }
      pdf
    end

    def pdf_document_stale?
      PdfDocument.where(template: template, json: data.to_json).count.zero?
    end

    def create_pdf_document(pdf = nil, filename = nil)
      pdf_document = PdfDocument.where(template: template, json: data.to_json.to_s).first
      return pdf_document if pdf_document
      pdf ||= to_pdf #generate pdf outside of transaction
      if self.class.instance_methods.include?(:pdf_filename)
        filename ||= self.pdf_filename
      else
        filename ||= "#{template.name}_#{Buzzn::Utils::Chronos.now.strftime('%Y%m%d_%H%M%S')}.pdf"
      end
      document = Document.new(filename: filename)
      PdfDocument.transaction do
        document.data = pdf
        document.save
        attrs = { template: template,
                  json: data.to_json,
                  document: document }
        PdfDocument.create!(attrs)
      end
    end

    protected

    def build_struct
      raise "not implemented #{self.class}"
    end

    def template_name
      method(:initialize).source_location[0].sub(/rb$/, 'slim').sub(%r(.*/), '')
    end

    def template
      @template ||= pdf_html_generator.resolve_template(template_name)
    end

    private

    def data
      @data ||= build_struct
    end

    def struct
      @struct ||= @builder.build(data)
    end

  end
end
