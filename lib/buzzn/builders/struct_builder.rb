require_relative '../builders'

class Builders::StructBuilder

  def initialize(struct_class = OpenStruct)
    @clazz = struct_class
  end

  def build(data)
    case data
    when Array then process_array(data)
    when Hash then process_hash(data)
    else raise 'not implemented'
    end
  end

  private

  def process_hash(hash)
    hash = hash.dup
    hash.each do |key, value|
      case value
      when Hash then hash[key] = process_hash(value)
      when Array then hash[key] = process_array(value)
      else value
      end
    end
    @clazz.new(hash)
  end

  def process_array(array)
    case array.first
    when NilClass then []
    when Hash then array.collect { |v| process_hash(v) }
    else array
    end
  end

end
