class LocalpoolLog

  attr_reader :messages, :localpool
  attr_writer :section
  attr_accessor :incompleteness, :warnings

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

  class MessageData

    def initialize(severity, text, section, extra_attributes = {})
      @severity, @text, @section, @extra_attributes = severity, text, section, extra_attributes
      @timestamp = Time.now.iso8601
    end

    def to_h
      hash = {
        # debug, info, warn, error
        severity:   @severity.upcase,
        text:       @text,
        # meters, registers, ...
        section:    @section,
        timestamp:  @timestamp
      }
      hash[:extra_data] = @extra_attributes[:extra_data] if @extra_attributes[:extra_data]
      hash
    end

  end

end
