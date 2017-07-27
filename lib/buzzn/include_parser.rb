require 'buzzn'
class Buzzn::IncludeParser

  attr_reader :result

  def self.parse(include)
    new.accept(include || '').result
  end

  def initialize
    @current = @result = {}
  end

  def accept(string)
    if index = string.index(/:|,/)
      name = string[0..index - 1].strip.to_sym
      remainder = string[index + 1..-1].strip
      case string[index]
      when ':'
        visit_nested(name, remainder)
      when ','
        visit_leaf(name, remainder)
      end
    elsif !string.empty?
      visit_leaf(string.strip.to_sym, '')
    end
    self
  end

  def find_right(string, start = 0)
    right = string.index(']', start)
    sub = string[1..right -1]
    if sub.count('[') != sub.count(']')
      find_right(string, right + 1)
    else
      right
    end
  end

  def visit_nested(name, remaining)
    old = @current
    @current = @current[name] = {}
    left = remaining.index('[')
    index = remaining.index(',') || remaining.size
    if left && left < index
      right = find_right(remaining)
      accept(remaining[left + 1..right - 1])
      index = remaining[right + 1..-1].index(',')
      index =+ right + 1 if index
    else
      accept(remaining[0..index])
    end
    @current = old
    last = remaining[index + 1..-1] if index
    accept(last) if last
  end

  def visit_leaf(name, remaining)
    @current[name] = {}
    accept(remaining)
  end
end
