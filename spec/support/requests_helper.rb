module RequestsHelper

  def login_cookie(account, path = '/login')
    $cookies ||= {}
    pwd = account.respond_to?(:password) ? account.password : 'Example123'
    cookie = account ? $cookies[account.id] : nil
    if account && cookie.nil?
      post '/login', {login: account.email, password: pwd}, {}
      cookie = response.headers['Set-Cookie']
      $cookies[account.id] = cookie
    end
    cookie
  end

  def do_it(action, path, params, token )
    headers = {
      "Accept"              => "application/json",
      "Content-Type"        => "application/json",
    }
    #session = Rack::Session::Cookie.new({}, secret: 'my secret')
    #value = session.send(:set_session, {}, {account_id: token.resource_owner_id}, {}, {}) if token
    #headers['HTTP_COOKIE'] = value

    case token
    when Doorkeeper::AccessToken
      headers["HTTP_AUTHORIZATION"]  = "Bearer #{token.token}"
    when Account::Base
      headers['HTTP_COOKIE'] = login_cookie(token)
    when NilClass
    else
      raise "can not handle #{token.class}"
    end

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

  def sort(hash, id = 'id')
    hash.sort{|n,m| m[id] <=> n[id]}
  end
end
