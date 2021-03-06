require_relative '../operations'

class Operations::ConvertKilowatt

  def call(params:, map:, **)
    map.each do |from, to|
      params[to] = convert(params.delete(from)) if params.key?(from)
    end
  end

  private

  def convert(value)
    value * 1000 if value
  end

end
