require 'buzzn/transactions/website/website_form/create'

describe Transactions::Website::WebsiteForm::Create do

  describe 'create' do

    let(:input) { {form_name: 'powertaker_v1', form_content: '{ "key": "value" }'} }

    entity(:resource) do
      WebsiteFormResource.all(nil)
    end

    it 'succeeds' do
      result = subject.call(params: input, resource: resource)
      expect(result).to be_success
      expect(result.value!).to be_a WebsiteFormResource
    end

    it 'fails' do
      expect { subject.call(params: {}, resource: resource) }.to raise_error Buzzn::ValidationError
    end

  end

end
