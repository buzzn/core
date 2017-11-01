describe Admin::BankAccountRoda do

  class BankAccountParentRoda < BaseRoda
    plugin :shared_vars
    route do |r|
      r.on 'test', :id do |id|
        rodauth.check_session_expiration

        localpool = Admin::LocalpoolResource.all(current_user).first
        localpool.object.persons
        parent = localpool.organizations.where(id: id).first || localpool.persons.where(id: id).first
        shared[Admin::BankAccountRoda::PARENT] = parent
        r.run Admin::BankAccountRoda
      end

      r.run Me::Roda
    end
  end

  def app
    BankAccountParentRoda # this defines the active application for this test
  end

  entity!(:localpool) do
    localpool = Fabricate(:localpool)
    $user.person.reload.add_role(Role::GROUP_MEMBER, localpool)
    localpool
  end

  entity!(:contract) { Fabricate(:metering_point_operator_contract,
                                 localpool: localpool,
                                 contractor: Fabricate(:other_organization)) }

  entity!(:person_account) do
    BankAccount.delete_all
    Fabricate(:bank_account, owner: contract.customer)
  end

  entity!(:organization_account) do
    Fabricate(:bank_account, owner: contract.contractor)
  end

  [:person_account, :organization_account].each do |name|
    context "#{name.to_s.sub(/_.*/,'')} parent" do

      let(:bank_account) { send(name) }
      let(:parent) { bank_account.owner }
      let(:bank_account_json) do
        {
          "id"=>bank_account.id,
          "type"=>"bank_account",
          'updated_at'=>bank_account.updated_at.as_json,
          "holder"=>bank_account.holder,
          "bank_name"=>bank_account.bank_name,
          "bic"=>bank_account.bic,
          "iban"=>bank_account.iban,
          "direct_debit"=>bank_account.direct_debit,
          'updatable' => true,
          'deletable' => true
        }
      end

      let(:wrong_json) do
        {
          "errors"=>[
            {"parameter"=>"holder",
             "detail"=>"size cannot be greater than 64"},
            {"parameter"=>"iban",
             "detail"=>"must be a string"},
            {"parameter"=>"bank_name",
             "detail"=>"size cannot be greater than 64"},
          ]
        }
      end

      context 'POST' do

        let(:create_denied_json) do
          {
            "errors" => [
              {
                "detail"=>"create_bank_account OrganizationResource: #{parent.id} permission denied for User: #{$user.id}" }
            ]
          }
        end

        let(:missing_json) do
          {
            "errors"=>[
              {"parameter"=>"bank_name", "detail"=>"is missing"},
              {"parameter"=>"holder", "detail"=>"is missing"},
              {"parameter"=>"iban", "detail"=>"is missing"},
            ]
          }
        end

        # can not construct users to see parent but not bank_account
        if name == :organization_account
          it '403' do
            POST "/test/#{parent.id}", $user, holder: 'someone', iban: 'DE23100000001234567890', bank_name: 'Limitless Limited', bic: '123123123XXX'
            expect(response).to have_http_status(403)
            expect(json).to eq create_denied_json
          end
        end

        it '422' do
          POST "/test/#{parent.id}", $admin,
               bank_name: 'blablub' * 20,
               holder: 'noone' * 20,
               iban: 123321
          expect(response).to have_http_status(422)
          expect(json.to_yaml).to eq wrong_json.to_yaml
        end
      end

      context 'PATCH' do
        let(:updated_json) do
          json = bank_account_json.dup
          json['holder'] = 'Max Mueller'
          json['bank_name'] = 'Bundesbank'
          json.delete('updated_at')
          json
        end

        let(:wrong_json) do
          {
            "errors"=>[
              {"parameter"=>"updated_at",
               "detail"=>"is missing"},
              {"parameter"=>"bank_name",
               "detail"=>"size cannot be greater than 64"},
              {"parameter"=>"holder",
               "detail"=>"size cannot be greater than 64"},
              {"parameter"=>"iban",
               "detail"=>"must be a valid iban"}
            ]
          }
        end

        it '401' do
          GET "/test/#{parent.id}/#{bank_account.id}", $admin
          expire_admin_session do
            PATCH "/test/#{parent.id}/#{bank_account.id}", $admin
            expect(response).to be_session_expired_json(401)
          end
        end

        # can not construct users to see parent but not bank_account
        if name == :organization_account
          it '403' do
            PATCH "/test/#{parent.id}/#{bank_account.id}", $user
            expect(response).to be_denied_json(403, bank_account)
          end
        end

        it '404' do
          PATCH "/test/#{parent.id}/bla-blub", $admin
          expect(response).to be_not_found_json(404, BankAccount)
        end

        it '409' do
          PATCH "/test/#{parent.id}/#{bank_account.id}", $admin,
                updated_at: DateTime.now
          expect(response).to be_stale_json(409, bank_account)
        end

        it '422' do
          PATCH "/test/#{parent.id}/#{bank_account.id}", $admin,
                holder: 'Max Mueller' * 10,
                bank_name: 'Bundesbank' * 10,
                iban: '12341234' * 20

          expect(response).to have_http_status(422)
          expect(json).to eq wrong_json
        end

        it '200' do
          old = bank_account.updated_at
          PATCH "/test/#{parent.id}/#{bank_account.id}", $admin,
                updated_at: bank_account.updated_at,
                bank_name: 'Bundesbank',
                holder: 'Max Mueller',
                iban: 'DE89 3704 0044 0532 0130 00'

          expect(response).to have_http_status(200)
          bank_account.reload
          expect(bank_account.holder).to eq 'Max Mueller'
          expect(bank_account.bank_name).to eq 'Bundesbank'
          expect(bank_account.iban).to eq 'DE89 3704 0044 0532 0130 00'

          result = json
          # TODO fix it: our time setup does not allow
          #expect(result.delete('updated_at')).to be > old.as_json
          expect(result.delete('updated_at')).not_to eq old.as_json
          expect(result.to_yaml).to eq updated_json.to_yaml
        end
      end

      context 'GET' do

        let(:bank_accounts_json) do
          [ bank_account_json ]
        end


        # can not construct users to see parent but not bank_account
        if name == :organization_account
          it '403' do
            GET "/test/#{parent.id}/#{bank_account.id}", $user
            expect(response).to be_denied_json(403, bank_account)
          end
        end

        it '404' do
          GET "/test/#{parent.id}/bla-blub", $admin
          expect(response).to be_not_found_json(404, BankAccount)
        end

        it '401' do
          GET "/test/#{parent.id}/#{bank_account.id}", $admin
          expire_admin_session do
            GET "/test/#{parent.id}/#{bank_account.id}", $admin
            expect(response).to be_session_expired_json(401)
          end
        end

        it '200' do
          GET "/test/#{parent.id}/#{bank_account.id}", $admin
          expect(response).to have_http_status(200)
          expect(json.to_yaml).to eq bank_account_json.to_yaml
        end

        it '200 all' do
          GET "/test/#{parent.id}", $admin
          expect(response).to have_http_status(200)
          expect(json['array'].to_yaml).to eq bank_accounts_json.to_yaml
        end
      end

      context 'DELETE' do

        # can not construct users to see parent but not bank_account
        if name == :organization_account
          it '403' do
            DELETE "/test/#{parent.id}/#{bank_account.id}", $user
            expect(response).to be_denied_json(403, bank_account)
          end
        end

        it '401' do
          GET "/test/#{parent.id}/#{bank_account.id}", $admin
          expire_admin_session do
            DELETE "/test/#{parent.id}/#{bank_account.id}", $admin
            expect(response).to be_session_expired_json(401)
          end
        end

        it '404' do
          DELETE "/test/#{parent.id}/bla-blub", $admin
          expect(response).to be_not_found_json(404, BankAccount)
        end

        it '204' do
          size = BankAccount.all.size

          DELETE "/test/#{parent.id}/#{bank_account.id}", $admin
          expect(response).to have_http_status(204)
          expect(BankAccount.all.size).to eq size - 1

          # recreate deleted
          BankAccount.create bank_account.attributes
        end
      end
    end
  end
end
