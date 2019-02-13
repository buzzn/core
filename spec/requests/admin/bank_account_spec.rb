describe Admin::BankAccountRoda, :request_helper do

  class BankAccountParentRoda < BaseRoda

    plugin :shared_vars
    route do |r|
      r.on 'test', :id do |id|
        rodauth.check_session_expiration

        localpool = Admin::LocalpoolResource.all(current_user).first
        parent = localpool.organizations.retrieve_or_nil(id) || localpool.persons.retrieve_or_nil(id)
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
    localpool = create(:group, :localpool)
    $user.person.reload.add_role(Role::GROUP_MEMBER, localpool)
    localpool
  end

  entity!(:contract) do
    create(:contract, :localpool_powertaker, localpool: localpool)
  end

  entity!(:person_account) do
    create(:bank_account, owner: contract.customer)
  end

  entity!(:organization_account) do
    create(:bank_account, owner: contract.contractor)
  end

  [:person_account, :organization_account].each do |name|
    context "#{name.to_s.sub(/_.*/, '')} parent" do

      def serialized_bank_account(bank_account)
        {
          'id'=>bank_account.id,
          'type'=>'bank_account',
          'created_at'=>bank_account.created_at.as_json,
          'updated_at'=>bank_account.updated_at.as_json,
          'holder'=>bank_account.holder,
          'bank_name'=>bank_account.bank_name,
          'bic'=>bank_account.bic,
          'iban'=>bank_account.iban,
          'direct_debit'=>bank_account.direct_debit,
          'updatable' => true,
          'deletable' => true
        }
      end

      let(:bank_account) { send(name) }
      let(:parent) { bank_account.owner }
      let(:bank_account_json) { serialized_bank_account(bank_account) }

      let(:wrong_json) do
        {
          'holder'=>['size cannot be greater than 64'],
          'iban'=>['must be a string'],
          'bank_name'=>['size cannot be greater than 64']
        }
      end

      context 'POST' do

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
            'updated_at'=>['is missing'],
            'holder'=>['size cannot be greater than 64'],
            'iban'=>['must be a valid iban'],
            'bank_name'=>['size cannot be greater than 64']
          }
        end

        it '401' do
          GET "/test/#{parent.id}/#{bank_account.id}", $admin
          expire_admin_session do
            PATCH "/test/#{parent.id}/#{bank_account.id}", $admin
            expect(response).to be_session_expired_json(401)
          end
        end

        it '404' do
          PATCH "/test/#{parent.id}/bla-blub", $admin
          expect(response).to have_http_status(404)
        end

        it '409' do
          PATCH "/test/#{parent.id}/#{bank_account.id}", $admin,
                updated_at: DateTime.now + 2.seconds
          expect(response).to have_http_status(409)
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
          parent.bank_accounts.reload.collect {|bank_account| serialized_bank_account(bank_account) }
        end

        it '404' do
          GET "/test/#{parent.id}/bla-blub", $admin
          expect(response).to have_http_status(404)
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
          expect(sort(json['array']).to_yaml).to eq sort(bank_accounts_json).to_yaml
        end
      end

      context 'DELETE' do

        it '401' do
          GET "/test/#{parent.id}/#{bank_account.id}", $admin
          expire_admin_session do
            DELETE "/test/#{parent.id}/#{bank_account.id}", $admin
            expect(response).to be_session_expired_json(401)
          end
        end

        it '404' do
          DELETE "/test/#{parent.id}/bla-blub", $admin
          expect(response).to have_http_status(404)
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
