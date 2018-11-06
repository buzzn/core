require_relative 'test_websiteform_roda'

describe Website::WebsiteFormRoda, :request_helper do

  def app
    CoreRoda
  end

  context 'POST' do

    it '422' do
      POST '/api/website/website-forms', nil,
           form_name: 'blablub'
      expect(response).to have_http_status(422)
    end

    it '201' do
      POST '/api/website/website-forms', nil,
           form_name: 'powertaker_v1',
           form_content: '{ "key": "value" }'
      expect(response).to have_http_status(201)
    end
  end

end

describe Website::WebsiteFormRoda, :request_helper do

  def app
    Website::TestWebsiteFormRoda
  end

  context 'GET' do

    it '403' do
      GET 'website/website-forms', nil
      expect(response).to have_http_status(403)
    end

    it '200' do
      GET 'website/website-forms', $admin
      expect(response).to have_http_status(200)
    end

  end

  context 'PATCH' do
    entity(:some_form) { create(:website_form) }

    entity(:update_params) do
      some_form.reload
      {
        :updated_at => some_form.updated_at,
        :processed => true
      }
    end

    it '403' do
      PATCH "website/website-forms/#{some_form.id}", nil, update_params
      expect(response).to have_http_status(403)
    end

    it '200' do
      PATCH "website/website-forms/#{some_form.id}", $admin, update_params
      expect(response).to have_http_status(200)
    end
  end

end
