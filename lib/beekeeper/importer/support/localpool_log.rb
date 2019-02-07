class LocalpoolLog

  attr_accessor :messages, :localpool, :section, :incompleteness, :warnings

  def initialize(localpool)
    @localpool = localpool
    @messages  = []
    @section   = nil
  end

  %w(debug info warn error).each do |method_name|
    define_method(method_name) do |text, extra_data = {}|
      @messages << message_data(method_name, text, extra_data)
    end
  end

  def with_section(section_name)
    previous_section = @section
    @section = section_name
    result = yield
    @section = previous_section
    result
  end

  private

  def message_data(method_name, text, extra_attributes = {})
    verify_extra_attributes!(extra_attributes)
    {
      timestamp: Time.now.iso8601,
      section:   @section, # example: meters, registers, ...
      severity:  method_name.upcase,
      text:      text
    }.merge(extra_attributes)
  end

  ALLOWED_EXTRA_ATTRIBUTES = %i(exception extra_data) #  error_source was replaced by section

  def verify_extra_attributes!(attrs)
    unless attrs.keys.all? { |attr| ALLOWED_EXTRA_ATTRIBUTES.include?(attr) }
      raise "Invalid extra attribute in: #{attrs.inspect} (allowed: #{ALLOWED_EXTRA_ATTRIBUTES.inspect})"
    end
  end
end
