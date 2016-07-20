module RequestsHelper

  def headers_with_token(token)
    headers = {
      "Accept"              => "application/json",
      "Content-Type"        => "application/json",
      "HTTP_AUTHORIZATION"  => "Bearer #{token}"
    }
  end

  def headers_without_token
    headers = {
      "Accept"              => "application/json",
      "Content-Type"        => "application/json"
    }
  end

  def get_with_token(path, params, token=nil, opts={})
    if ! params.is_a?(Hash) && token.nil?
      token = params
      params = {}
    end

    get path, params, headers_with_token(token).merge!(opts)
  end

  def get_without_token(path, params={}, opts={})
    get path, params, headers_without_token.merge!(opts)
  end



  def post_with_token(path, params={}, token)
    post path, params, headers_with_token(token)
  end

  def post_without_token(path, params={})
    post path, params, headers_without_token
  end



  def put_with_token(path, params={}, token)
    put path, params, headers_with_token(token)
  end

  def put_without_token(path, params={})
    put path, params, headers_without_token
  end


  def delete_with_token(path, token)
    delete path, {}, headers_with_token(token)
  end

  def delete_without_token(path)
    delete path, {}, headers_without_token
  end


  def json
    JSON.parse(response.body)
  end

  def to_time(key)
    DateTime.parse(response[key]).to_time
  end

  def split(key)
    response[key].split(/, ?/)
  end
end
