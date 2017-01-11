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

  def get_with_token(path, params={}, token)
    get path, params, headers_with_token(token)
    if response.status == 500
      puts response.body
    end
  end

  def get_without_token(path, params={})
    get path, params, headers_without_token
    if response.status == 500
      puts response.body
    end
  end



  def post_with_token(path, params={}, token)
    post path, params, headers_with_token(token)
    if response.status == 500
      puts response.body
    end
  end

  def post_without_token(path, params={})
    post path, params, headers_without_token
    if response.status == 500
      puts response.body
    end
  end



  def patch_with_token(path, params={}, token)
    patch path, params, headers_with_token(token)
    if response.status == 500
      puts response.body
    end
  end

  def patch_without_token(path, params={})
    patch path, params, headers_without_token
    if response.status == 500
      puts response.body
    end
  end

  def put_with_token(path, params={}, token)
    put path, params, headers_with_token(token)
    if response.status == 500
      puts response.body
    end
  end

  def put_without_token(path, params={})
    put path, params, headers_without_token
    if response.status == 500
      puts response.body
    end
  end


  def delete_with_token(path, params={}, token)
    delete path, params, headers_with_token(token)
    if response.status == 500
      puts response.body
    end
  end

  def delete_without_token(path, params={})
    delete path, params, headers_without_token
    if response.status == 500
      puts response.body
    end
  end

  def verbose
    puts json.to_yaml rescue nil
  end

  def json
    JSON.parse(response.body)
  end
end
