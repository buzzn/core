require_relative '../discovergy'

class Types::Discovergy::Base

  def to_path
    raise 'not implemented'
  end

  def to_query
    {}
  end

  def to_uri(base)
    result = base.dup << '/' << to_path.to_s
    sep = '?'
    to_query.each do |key, value|
      result << sep << key.to_s << '='
      result << (value.is_a?(Array) ? value.join(',') : value.to_s)
      sep = '&'
    end
    result
  end

end
