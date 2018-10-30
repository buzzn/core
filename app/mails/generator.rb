module Mail
  class Generator

    include Import.reader['services.mail_generator']

    class MailStruct < OpenStruct

      def method_missing(method, *args, &block)
        if respond_to?(method)
          super
        else
          "__#{method}__" || super
        end
      end

      def respond_to_missing?(*)
        true
      end

    end

    def initialize(root_object, **)
      @root = root_object
      @builder = Builders::StructBuilder.new(MailStruct)
    end

    def to_html
      mail_generator.render_html(template_name, struct)
    end

    def to_text
      mail_generator.render_text(template_name, struct)
    end

    protected

    def template_name
      method(:initialize).source_location[0].sub(/.rb$/, '').sub(%r(.*/), '')
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
