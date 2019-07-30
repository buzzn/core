module RequestsHelper

  def self.included(spec)
    spec.extend(ClassMethods)
  end

  module ClassMethods

    def login_path(path = nil)
      (@login_path ||= path) ||
        (superclass.respond_to?(:login_path) ? superclass.login_path : nil)
    end

  end

  def login_path
    self.class.login_path || '/login'
  end

  def authorize(account, headers = {})
    $authorizations ||= {}
    pwd = account.respond_to?(:password) ? account.password : 'Example123'
    token = account ? $authorizations[account.id] : nil
    if account && token.nil?
      post login_path, {login: account.email, password: pwd}.to_json, {'Content-Type' => 'application/json'}.merge(headers)
      token = response.headers['Authorization']
      $authorizations[account.id] = token
    end
    token
  end

  def do_it(action, path, params, account, headers = {})
    default_headers = {
      'Accept'              => 'application/json',
      'Content-Type'        => 'application/json',
    }
    account = account.call if account.is_a? Proc
    case account
    when Account::Base
      default_headers['Authorization'] = authorize(account, headers)
    when NilClass
    else
      raise "can not handle #{account.class}"
    end
    send action, path, params, default_headers.merge(headers)

    if response.status == 500
      puts json.to_yaml rescue response.body
    end
  end
  private :do_it

  def GET(path, token = nil, params = {}, headers = {})
    do_it(:get, path, params, token, headers)
  end

  def PATCH(path, token = nil, params = {}, headers = {})
    do_it(:patch, path, params.to_json, token, headers)
  end

  def POST(path, token = nil, params = {}, headers = {})
    do_it(:post, path, params.to_json, token, headers)
  end

  def PUT(path, token = nil, params = {}, headers = {})
    do_it(:put, path, params, token, headers)
  end

  def DELETE(path, token = nil, params = {}, headers = {})
    do_it(:delete, path, params, token, headers)
  end

  def json
    JSON.parse(response.body)
  end

  def expire_admin_session
    Timecop.travel(Time.now + 60 * 60) do
      yield
    end
  end

  def sort_array_of_hash(array, id = 'id')
    array.sort{|n, m| m[id] <=> n[id]}
  end
  alias sort sort_array_of_hash

  def sort_hash(h)
    case h
    when Array
      sort_array(h)
    when Hash
      h.each { |k, v| h[k] = sort_element(v) }
      Hash[h.sort]
    end
  end

  private

  def sort_element(v)
    case v
    when Hash
      sort_hash(v)
    when Array
      sort_array(v)
    end
  end

  def sort_array(a)
    case a.first
    when Hash
      a.collect {|h| sort_hash(h)}
    else
      a.sort
    end
  end

end
