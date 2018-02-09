class ApiMock

  attr_writer :result
  attr_reader :query

  def request(query, *)
    @query = query.to_uri('')
    case @result
    when Array then @result.collect { |r| OpenStruct.new(r) }
    when String then nil
    else OpenStruct.new(@result)
    end
  end

end
