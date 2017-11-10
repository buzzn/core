# we can not have nested transactions on AR connection and use Sequel at the
# same time as it does not see the entities from AR connection
describe Me::Roda, :skip_nested do

  def app
    CoreRoda # use full stack as we need to test CORS config as well
  end

  login_path '/api/me/login'

  entity!(:user) do
    user = Fabricate(:user)
    def user.password; 'Example123'; end
    user
  end

  after :all do
    [Account::PasswordHash, Account::PasswordResetKey, Account::LoginChangeKey, Account::Base].each do |model|
      model.where(id: user).delete_all
    end
  end

  entity(:password) { 'Example123' }


  let(:invalid_password_json) do
    {
      "errors"=>[
        {"parameter"=>"password", "detail"=>"invalid password"}
      ]
    }
  end

  let(:no_matching_passwords_json) do
    {
      "errors"=>[
        {"parameter"=>"password", "detail"=>"passwords do not match"}
      ]
    }
  end

  context 'login' do

    let(:no_matching_login_json) do
      {
        "errors"=>[
          {"parameter"=>"login", "detail"=>"no matching login"}
        ]
      }
    end

    it '200' do
      expect(authorize(user)).not_to be_nil

      GET '/api/me', user, {}, { 'Origin' => 'http://localhost:2999' }
      expect(response.headers['Access-Control-Expose-Headers']).to eq 'Authorization'
      expect(response).to have_http_status(200)
      expect(json['id']).to eq user.person.id
    end

    it '422' do
      POST '/api/me/login', nil
      expect(response).to have_http_status(422)
      expect(json).to eq no_matching_login_json

      POST '/api/me/login', nil, login: user.email
      expect(response).to have_http_status(422)
      expect(json).to eq invalid_password_json
    end
  end

  context 'change-password' do

    let(:no_matching_new_passwords_json) do
      {
        "errors"=>[
          {"parameter"=>"new-password", "detail"=>"passwords do not match"}
        ]
      }
    end

    let(:invalid_new_password_json) do
      {
        "errors"=>[
          {"parameter"=>"new-password", "detail"=>"invalid password, does not meet requirements (minimum 6 characters)"}
        ]
      }
    end

    it '200' do
      POST '/api/me/change-password', user,
           password: user.password,
           'new-password': 'NewExample123',
           'password-confirm': 'NewExample123'
      expect(response).to have_http_status(200)
      hash = Account::PasswordHash.where(id: user.id).first
      expect(BCrypt::Password.new(hash.password_hash)).to eq 'NewExample123'

      def user.password; 'NewExample123'; end
    end

    it '401' do
      POST '/api/me/change-password', nil,
           password: 'some.password',
           'new-password': 'something',
           'password-confirm': 'something'
      expect(response).to have_http_status(401)
    end

    it '422' do
      POST '/api/me/change-password', user,
           'new-password': 'something',
           'password-confirm': 'something'
      expect(response).to have_http_status(422)
      expect(json).to eq invalid_password_json

      POST '/api/me/change-password', user,
           password: user.password,
           'password-confirm': 'NewExample123'
      expect(response).to have_http_status(422)
      expect(json).to eq no_matching_new_passwords_json

      POST '/api/me/change-password', user,
           password: user.password,
           'new-password': 'NewExample123'
      expect(response).to have_http_status(422)
      expect(json).to eq no_matching_new_passwords_json

      POST '/api/me/change-password', user,
           password: user.password
      expect(response).to have_http_status(422)
      expect(json).to eq invalid_new_password_json
    end
  end

  context 'change-login' do

    let(:invalid_login_json) do
      {
        "errors"=>[
          {"parameter"=>"login",
           "detail"=>"invalid login, minimum 3 characters"}
        ]
      }
    end

    let(:no_matching_logins_json) do
      {
        "errors"=>[
          {"parameter"=>"login",
           "detail"=>"logins do not match"}
        ]
      }
    end

    it '200' do
      POST '/api/me/change-login', user,
           password: user.password,
           login: 'someone@buzzn.net',
           'login-confirm': 'someone@buzzn.net'
      expect(response).to have_http_status(200)
      expect(user.reload.email).not_to eq 'someone@buzzn.net'
      key = Account::LoginChangeKey.where(id: user.id).first
      expect(key.login).to eq 'someone@buzzn.net'
    end

    it '422' do
      POST '/api/me/change-login', user,
           password: 'some.password',
           login: 'someone@buzzn.net',
           'login-confirm': 'someone@buzzn.net'
      expect(response).to have_http_status(422)
      expect(json).to eq invalid_password_json

      POST '/api/me/change-login', user,
           login: 'someone@buzzn.net',
           'login-confirm': 'someone@buzzn.net'
      expect(response).to have_http_status(422)
      expect(json).to eq invalid_password_json

      POST '/api/me/change-login', user,
           password: user.password,
           'login-confirm': 'someone@buzzn.net'
      expect(response).to have_http_status(422)
      expect(json).to eq invalid_login_json

      POST '/api/me/change-login', user,
           password: user.password,
           login: 'someone@buzzn.net'
      expect(response).to have_http_status(422)
      expect(json).to eq no_matching_logins_json
    end
  end

  context 'verify-login-change' do

    before(:each) do
      POST '/api/me/change-login', user,
           password: user.password,
           login: login,
           'login-confirm': login
    end

    let(:login) { "next.#{user.email}" }
    let(:key) { Account::LoginChangeKey.where(id: user.id).first.key }

    it '200' do
      POST '/api/me/verify-login-change', nil,
           key: "#{user.id}_#{key}"
      expect(response).to have_http_status(200)
      expect(user.reload.email).to eq login
    end

    it '401' do
      POST '/api/me/verify-login-change', nil,
           key: "#{user.id}_somekey"
      expect(response).to have_http_status(401)
      expect(user.reload.email).not_to eq login

      POST '/api/me/verify-login-change', nil,
           key: "321123321_#{key}"
      expect(response).to have_http_status(401)
      expect(user.reload.email).not_to eq login
    end

  end

  context 'reset-password-request' do

    it '200' do
      POST '/api/me/reset-password-request', nil,
           login: user.email
      expect(response).to have_http_status(200)
    end

    it '401' do
      POST '/api/me/reset-password-request', nil,
           login: 'some@email'
      expect(response).to have_http_status(401)

      POST '/api/me/reset-password-request', nil
      expect(response).to have_http_status(401)
    end
  end

  context 'reset-password' do

    before(:each) do
      POST '/api/me/reset-password-request', nil,
           login: user.email
    end

    let(:key) do
      Account::PasswordResetKey.where(id: user.id).first.key
    end

    it '200' do
      POST '/api/me/reset-password', nil,
           key: "#{user.id}_#{key}",
           password: 'AnotherExample123',
           'password-confirm': 'AnotherExample123'
      expect(response).to have_http_status(200)

      def user.password; 'AnotherExample123'; end
    end

    it '401' do
      POST '/api/me/reset-password', nil,
           password: 'AnotherExample123',
           'password-confirm': 'AnotherExample123'
      expect(response).to have_http_status(401)

      POST '/api/me/reset-password', nil,
           key: "#{user.id}_somekey",
           password: 'AnotherExample123',
           'password-confirm': 'AnotherExample123'
      expect(response).to have_http_status(401)

      POST '/api/me/reset-password', nil,
           key: "321123321_#{key}",
           password: 'AnotherExample123',
           'password-confirm': 'AnotherExample123'
      expect(response).to have_http_status(401)
    end

    let(:invalid_password_same_as_current_json) do
      {
        "errors"=>[
          {"parameter"=>"password",
           "detail"=>"invalid password, same as current password"}
        ]
      }
    end

    let(:invalid_password_json) do
      {
        "errors"=>[
          {"parameter"=>"password", "detail"=>"invalid password, does not meet requirements (minimum 6 characters)"}
        ]
      }
    end

    it '422' do
      POST '/api/me/reset-password', nil,
           key: "#{user.id}_#{key}",
           'password-confirm': 'YetAnotherExample123'
      expect(response).to have_http_status(422)
      expect(json).to eq no_matching_passwords_json

      POST '/api/me/reset-password', nil,
           key: "#{user.id}_#{key}",
           'password': 'YetAnotherExample123'
      expect(response).to have_http_status(422)
      expect(json).to eq no_matching_passwords_json


      POST '/api/me/reset-password', nil,
           key: "#{user.id}_#{key}",
           password: user.password,
           'password-confirm': user.password
      expect(response).to have_http_status(422)
      expect(json).to eq invalid_password_same_as_current_json

      POST '/api/me/reset-password', nil,
           key: "#{user.id}_#{key}"
      expect(response).to have_http_status(422)
      expect(json).to eq invalid_password_json
    end
  end

  context 'logout' do

    it '200' do
      POST '/api/me/logout', user
      expect(response).to have_http_status(200)
      $authorizations[user.id] = response['Authorization']

      GET '/api/me', user
      expect(response).to have_http_status(403)
      $authorizations.delete(user.id)
    end
  end
end
