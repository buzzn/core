require 'buzzn/schemas/support/visitor'
require 'buzzn/schemas/transactions/chart'
require 'buzzn/schemas/transactions/display/score'

describe Display do
  include SwaggerHelper

  def app
    CoreRoda
  end

  login_path '/api/me/login'

  entity!(:group) { create(:localpool) }

  entity!(:register) { create(:meter, :real, group: group).input_register }

  swagger do |s|
    s.basePath = '/api/display'
  end

  get '/groups' do
    description 'return all public groups'
  end

  get '/groups/{group.id}' do
    description 'returns the group'
  end

  get '/groups/{group.id}/scores' do
    description 'returns the score(s) of the group'
    schema Schemas::Transactions::Display::Score
  end

  get '/groups/{group.id}/mentors' do
    description 'returns the mentors of the group'
  end

  get '/groups/{group.id}/bubbles' do
    description 'returns the bubbles of the group'
  end

  get '/groups/{group.id}/charts' do
    description 'returns the charts of the group'
    schema Schemas::Transactions::Chart
  end

  get '/groups/{group.id}/registers' do
    description 'returns all registers'
  end

  get '/groups/{group.id}/registers/{register.id}' do
    description 'returns the register'
  end

  get '/groups/{group.id}/registers/{register.id}/ticker' do
    description 'returns the power ticker of the register'
  end

  get '/groups/{group.id}/registers/{register.id}/charts' do
    description 'returns the charts of the group'
    schema Schemas::Transactions::Chart
  end

  it 'GET /swagger.json' do
    GET swagger.basePath + '/swagger.json', $admin
    expect(response).to have_http_status(200)
    expect(json).not_to be_nil
  end
end
