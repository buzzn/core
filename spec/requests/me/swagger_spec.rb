require 'buzzn/schemas/support/visitor'
require 'buzzn/schemas/transactions/me/login'
require 'buzzn/schemas/transactions/me/change_login'
require 'buzzn/schemas/transactions/me/verify_change_login'
require 'buzzn/schemas/transactions/me/logout'
require 'buzzn/schemas/transactions/me/reset_password'
require 'buzzn/schemas/transactions/me/reset_password_request'

# we can not have nested transactions on AR connection and use Sequel at the
# same time as it does not see the entities from AR connection
describe Me, :swagger, :skip_nested, :request_helper do
  include SwaggerHelper

  def app
    CoreRoda
  end

  login_path '/api/me/login'

  entity!(:account) { Proc.new { @a ||= create(:account, :self, password: 'Example123') } }
  entity!(:account_change_login) { Proc.new { @b ||= create(:account, :self, password: 'Example123') } }

  after :all do
    [account.call, account_change_login.call].each do |a|
      [Account::PasswordHash, Account::PasswordResetKey, Account::LoginChangeKey, Account::Base].each do |model|
        model.where(id: a).delete_all
      end
    end
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
    schema Schemas::Transactions::Person::Update
  end

  post '/login', nil, status: 200, description: 'logged in' do
    description 'login'
    schema Schemas::Transactions::Me::Login, ''
  end

  post '/reset-password-request', nil, status: 200, description: 'key sent via email' do
    description 'request key for resetting password'
    schema Schemas::Transactions::Me::ResetPasswordRequest, ''
  end

  post '/reset-password', nil, status: 200, description: 'new password set' do
    description 'reset password with given key'
    schema Schemas::Transactions::Me::ResetPassword, ''
  end

  post '/change-login', account_change_login, status: 200, description: 'change login key sent via email' do
    description 'change login and verify with key'
    schema Schemas::Transactions::Me::ChangeLogin, ''
  end

  post '/verify-login-change', account, status: 200, description: 'login verfied and changed' do
    description 'verify login change with key'
    schema Schemas::Transactions::Me::VerifyChangeLogin, ''
  end

  post '/logout', account, status: 200, description: 'logged out' do
    description 'logout'
    schema Schemas::Transactions::Me::Logout
  end

  # swagger

  it 'GET /swagger.json' do
    GET swagger.basePath + '/swagger.json', $admin
    expect(response).to have_http_status(200)
    expect(json).not_to be_nil
  end
end
