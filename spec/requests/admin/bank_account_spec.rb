describe Admin::BankAccountRoda do

  class BankAccountParentRoda < BaseRoda
    plugin :shared_vars
    route do |r|
      r.on :id do |id|
        parent = User.where(id: id).first || Organization.where(id: id).first
        shared[Admin::BankAccountRoda::PARENT] = ContractingPartyResource.new(parent, current_user: current_user)
        r.run Admin::BankAccountRoda
      end
    end
  end

  def app
    BankAccountParentRoda # this defines the active application for this test
  end

  entity!(:user_account) do
    Fabricate(:bank_account)
  end

  entity!(:organization_account) do
    orga = Fabricate(:other_organization)
    Fabricate(:bank_account, contracting_party: orga)
  end

  entity(:admin) { Fabricate(:admin_token) }

  entity(:user) { Fabricate(:user_token) }

  let(:not_found_json) do
    {
      "errors" => [
        {
          "detail"=>"BankAccount: bla-bla-blub not found by User: #{admin.resource_owner_id}" }
      ]
    }
  end

  [:user_account, :organization_account].each do |name|
    context "#{name.to_s.sub(/_.*/,'')} parent" do

      let(:bank_account) { send(name) }
      let(:parent) { bank_account.contracting_party }
      let(:bank_account_json) do
        {
          "id"=>bank_account.id,
          "type"=>"bank_account",
          "holder"=>bank_account.holder,
          "bank_name"=>bank_account.bank_name,
          "bic"=>bank_account.bic,
          "iban"=>bank_account.iban,
          "direct_debit"=>bank_account.direct_debit
        }
      end

      let(:denied_json) do
        {
          "errors" => [
            {
              "detail"=>"retrieve BankAccount: #{bank_account.id} permission denied for User: #{user.resource_owner_id}" }
          ]
        }
      end

      let(:wrong_json) do
        {
          "errors"=>[
            {"parameter"=>"bank_name", "detail"=>"size cannot be greater than 63"},
            {"parameter"=>"holder", "detail"=>"size cannot be greater than 63"},
            {"parameter"=>"iban", "detail"=>"must be a valid iban"}
          ]
        }
      end

      context 'POST' do

        let(:missing_json) do
          {
            "errors"=>[
              {"parameter"=>"bank_name", "detail"=>"is missing"},
              {"parameter"=>"holder", "detail"=>"is missing"},
              {"parameter"=>"iban", "detail"=>"is missing"},
            ]
          }
        end

        it '403' do
          # TODO permissions checks needed

          #          POST "/#{parent.id}", user
#          expect(response).to have_http_status(403)
#          expect(json).to eq denied_json
        end

        it '422 missing' do
          POST "/#{parent.id}", admin
          expect(response).to have_http_status(422)
          expect(json.to_yaml).to eq missing_json.to_yaml
        end

        it '422 wrong' do
          POST "/#{parent.id}", admin,
               bank_name: 'blablub' * 20,
               holder: 'noone' * 20,
               iban: 123321
          expect(response).to have_http_status(422)
          expect(json.to_yaml).to eq wrong_json.to_yaml
        end

        it '201' do
        end
      end

      context 'PATCH' do
        let(:updated_json) do
          json = bank_account_json.dup
          json['holder'] = 'Max Mueller'
          json
        end

        it '403' do
          PATCH "/#{parent.id}/#{bank_account.id}", user
          expect(response).to have_http_status(403)
          expect(json).to eq denied_json
        end

        it '404' do
          PATCH "/#{parent.id}/bla-bla-blub", admin
          expect(response).to have_http_status(404)
          expect(json).to eq not_found_json
        end

        it '422 wrong' do
          PATCH "/#{parent.id}/#{bank_account.id}", admin,
                holder: 'Max Mueller' * 10,
                bank_name: 'Bundesbank' * 10,
                iban: 12341234
          
          expect(response).to have_http_status(422)
          expect(json).to eq wrong_json
        end

        it '200' do
          PATCH "/#{parent.id}/#{bank_account.id}", admin, holder: 'Max Mueller'
          expect(response).to have_http_status(200)
          expect(bank_account.reload.holder).to eq 'Max Mueller'
          expect(json.to_yaml).to eq updated_json.to_yaml
        end
      end

      context 'GET' do

        let(:bank_accounts_json) do
          [ bank_account_json ]
        end

        it '403' do
          GET "/#{parent.id}/#{bank_account.id}", user
          expect(response).to have_http_status(403)
          expect(json).to eq denied_json
        end

        it '404' do
          GET "/#{parent.id}/bla-bla-blub", admin
          expect(response).to have_http_status(404)
          expect(json).to eq not_found_json
        end

        it '200' do
          GET "/#{parent.id}/#{bank_account.id}", admin
          expect(response).to have_http_status(200)
          expect(json.to_yaml).to eq bank_account_json.to_yaml
        end

        it '200 all' do
          GET "/#{parent.id}", admin
          expect(response).to have_http_status(200)
          expect(json['array'].to_yaml).to eq bank_accounts_json.to_yaml
        end
      end
      
      context 'DELETE' do

        it '403' do
          DELETE "/#{parent.id}/#{bank_account.id}", user
          expect(response).to have_http_status(403)
          expect(json).to eq denied_json
        end

        it '404' do
          DELETE "/#{parent.id}/bla-bla-blub", admin
          expect(response).to have_http_status(404)
          expect(json).to eq not_found_json
        end

        it '204' do
          size = BankAccount.all.size

          DELETE "/#{parent.id}/#{bank_account.id}", admin
          expect(response).to have_http_status(204)
          expect(BankAccount.all.size).to eq size - 1

          # recreate deleted
          BankAccount.create bank_account.attributes
        end
      end
    end
  end
end
