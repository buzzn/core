require 'buzzn/schemas/support/visitor'
# we can not have nested transactions on AR connection and use Sequel at the
# same time as it does not see the entities from AR connection
describe Me, :swagger, :skip_nested do
  include SwaggerHelper

  def app
    CoreRoda
  end

  login_path '/api/me/login'

  entity!(:account) { Proc.new { @a ||= Fabricate(:user) } }
  entity!(:account_change_login) { Proc.new { @b ||= Fabricate(:user) } }

  after :all do
    load 'db/setup_data/common.rb'
  end

  # me
  get '/', account do
    description 'returns me (person) of the current logged in user'
  end

  get '/ping', account do
    description "returns 'pong'"
  end

  patch '/', account do
    description 'updates me (person) of the current logged in user'
    schema 'update_person'
  end

  post '/login', nil, status: 200, description: 'logged in' do
    description 'login'
    schema 'login', [{"parameter"=>"login", "detail"=>"no matching login"}]
  end

  post '/reset-password-request', nil, status: 200, description: 'key sent via email' do
    description 'request key for resetting password'
    schema 'reset_password_request', []
  end

  post '/reset-password', nil, status: 200, description: 'new password set' do
    description 'reset password with given key'
    schema 'reset_password', []
  end

  post '/change-login', account_change_login, status: 200, description: 'change login key sent via email' do
    description 'change login and verify with key'
    schema 'change_login', [{"parameter"=>"password", "detail"=>"invalid password"}]
  end

  post '/verify-login-change', account, status: 200, description: 'login verfied and changed' do
    description 'verify login change with key'
    schema 'verify_login_change', []
  end

  post '/logout', account, status: 200, description: 'logged out' do
    description 'logout'
    schema 'logout'
  end

  # swagger

  it 'GET /swagger.json' do
    GET swagger.basePath + '/swagger.json', $admin
    expect(response).to have_http_status(200)
    expect(json).not_to be_nil
  end
end
