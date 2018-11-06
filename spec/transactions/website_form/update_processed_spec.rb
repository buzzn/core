require 'buzzn/transactions/website/website_form/create'

describe Transactions::Website::WebsiteForm::UpdateProcessed do

  entity(:form) do
    create(:website_form)
  end

  entity(:operator) { create(:account, :buzzn_operator) }

  entity(:resource) do
    WebsiteFormResource.all(operator).retrieve(form.id)
  end

  let(:processed_true_params) do
    form.reload
    {
      :updated_at => form.updated_at.as_json,
      :processed => true
    }
  end

  let(:processed_false_params) do
    form.reload
    {
      :updated_at => form.updated_at.as_json,
      :processed => false
    }
  end

  let(:result_true) do
    Transactions::Website::WebsiteForm::UpdateProcessed.new.(resource: resource, params: processed_true_params)
  end

  let(:result_false) do
    Transactions::Website::WebsiteForm::UpdateProcessed.new.(resource: resource, params: processed_false_params)
  end

  it 'updates and changes to processed' do
    expect(result_true).to be_success
    form.reload
    expect(form.processed).to eql true
  end

  it 'updates and changes to unprocessed' do
    expect(result_false).to be_success
    form.reload
    expect(form.processed).to eql false
  end

end
