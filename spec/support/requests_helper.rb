module RequestsHelper

  def self.included(spec)
    spec.extend(ClassMethods)
  end

  module ClassMethods
    def login_path(path = nil)
      (@login_path ||= path) ||
        (superclass.respond_to?(:login_path) ? superclass.login_path : nil)
    rescue
      binding.pry
    end
  end

  def login_path
    self.class.login_path || raise('login path not set')
  end

  def authorize(account)
    $authorizations ||= {}
    pwd = account.respond_to?(:password) ? account.password : 'Example123'
    token = account ? $authorizations[account.id] : nil
    if account && token.nil?
      post login_path, {login: account.email, password: pwd}.to_json, {'Content-Type': 'application/json'}
      token = response.headers['Authorization']
      $authorizations[account.id] = token
    end
    token
  end

  def do_it(action, path, params, account )
    headers = {
      "Accept"              => "application/json",
      "Content-Type"        => "application/json",
    }
    account = account.call if account.is_a? Proc
    case account
    when Doorkeeper::AccessToken
      headers["HTTP_AUTHORIZATION"]  = "Bearer #{account.token}"
    when Account::Base
      headers['Authorization'] = authorize(account)
    when NilClass
    else
      raise "can not handle #{account.class}"
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
