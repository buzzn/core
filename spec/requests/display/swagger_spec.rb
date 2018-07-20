require 'buzzn/schemas/support/visitor'
require 'buzzn/schemas/transactions/chart'
require 'buzzn/schemas/transactions/display/score'

describe Display, :request_helper do
  include SwaggerHelper

  def app
    CoreRoda
  end

  login_path '/api/me/login'

  entity!(:group) { create(:group, :localpool, show_display_app: true) }

  swagger do |s|
    s.basePath = '/api/display'
  end

  get '/groups' do
    description 'return all public groups'
  end

  get '/groups/{group.id}' do
    description 'returns the group'
  end

  get '/groups/{group.id}/mentors' do
    description 'returns the mentors of the group'
  end

  get '/groups/{group.id}/bubbles' do
    description 'returns the bubbles of the group'
  end

  get '/groups/{group.id}/charts' do
    description 'returns the daily charts of the group'
  end

  it 'GET /swagger.json' do
    GET swagger.basePath + '/swagger.json', $admin
    expect(response).to have_http_status(200)
    expect(json).not_to be_nil
  end
end
