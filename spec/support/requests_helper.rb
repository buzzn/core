module RequestsHelper


  def do_it(action, path, params, token )
    headers = {
      "Accept"              => "application/json",
      "Content-Type"        => "application/json",
    }
    headers["HTTP_AUTHORIZATION"]  = "Bearer #{token.token}" if token
               
    send action, path, params, headers
    
    if response.status == 500
      puts json.to_yaml rescue response.body
    end
  end
  private :do_it

  def GET(path, token = nil, params = {})
    do_it :get, path, params, token
  end

  def PATCH(path, token = nil, params = {})
    do_it(:patch, path, params.to_json, token)
  end

  def POST(path, token = nil, params = {})
    do_it :post, path, params.to_json, token
  end

  def PUT(path, token = nil, params = {})
    do_it :put, path, params, token
  end

  def DELETE(path, token = nil, params = {})
    do_it :delete, path, params, token
  end

  def json
    JSON.parse(response.body)
  end

  def sort(hash)
    hash.sort{|n,m| m['id'] <=> n['id']}
  end
end
