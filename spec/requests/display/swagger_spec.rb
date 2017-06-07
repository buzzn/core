describe Display do
  include SwaggerHelper

  def app
    CoreRoda
  end

  entity!(:group) { Fabricate([:localpool, :tribe].sample) }

  entity!(:register) do
    register = Fabricate(:meter).registers.first
    register.update(group: group)
    register
  end

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
    schema 'scores_schema'
  end

  get '/groups/{group.id}/mentors' do
    description 'returns the mentors of the group'
  end

  get '/groups/{group.id}/bubbles' do
    description 'returns the bubbles of the group'
  end

  get '/groups/{group.id}/charts' do
    description 'returns the charts of the group'
    schema 'charts_schema'
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
    schema 'charts_schema'
  end
end
