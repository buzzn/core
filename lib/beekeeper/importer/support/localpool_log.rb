class LocalpoolLog

  attr_reader :messages, :localpool
  attr_writer :section, :incompleteness, :warnings

  def initialize(localpool)
    @localpool = localpool
    @messages  = []
    @section   = nil
  end

  %w(debug info warn error).each do |method_name|
    define_method(method_name) do |text, extra_attributes = {}|
      @messages << MessageData.new(method_name, text, @section, extra_attributes)
    end
  end

  def with_section(section_name)
    previous_section = @section
    @section = section_name
    result = yield
    @section = previous_section
    result
  end

  def warnings
    @warnings.map do |key, value|
      text = "#{key}: #{value}"
      MessageData.new(:warn, text, 'warnings').to_h
    end
  end

  def incompleteness
    messages = []
    @incompleteness.each do |field, data|
      text = if data.is_a?(Hash)
               data.each do |sub_field, sub_field_messages|
                 text = "#{field}/#{sub_field}: #{sub_field_messages.join(', ')}"
                 sub_field_messages << MessageData.new(:warn, text, 'incompleteness').to_h
               end
             elsif data.is_a?(Array)
               text = "#{field}: #{data.join(', ')}"
               messages << MessageData.new(:warn, text, 'incompleteness').to_h
             else
               raise 'Unexpected data on incompleteness'
             end
    end
    messages
  end

  class MessageData

    def initialize(severity, text, section, extra_attributes = {})
      @severity, @text, @section, @extra_attributes = severity, text, section, extra_attributes
      @timestamp = Time.now.iso8601
    end

    def to_h
      {
        # debug, info, warn, error
        severity:   @severity.upcase,
        text:       @text,
        # meters, registers, ...
        section:    @section,
        timestamp:  @timestamp,
        extra_data: @extra_attributes[:extra_data]
      }
    end

  end

end
