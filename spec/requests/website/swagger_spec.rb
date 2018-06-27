require 'buzzn/schemas/support/visitor'
require 'buzzn/schemas/transactions/website/zip_to_price'

describe 'Website', :request_helper do
  include SwaggerHelper

  def app
    CoreRoda
  end

  swagger do |s|
    s.basePath = '/api/website'
  end

  post '/zip-to-price' do
    description 'calculates the price for the given zipcode'
    schema Schemas::Transactions::Website::ZipToPrice
  end

  it 'GET /swagger.json' do
    GET swagger.basePath + '/swagger.json', $admin
    expect(response).to have_http_status(200)
    expect(json).not_to be_nil
  end
end
