describe "#{Buzzn::Permission} - #{PersonResource}" do

  entity(:admin) { create(:account, :buzzn_operator, :self) }
  entity!(:me) do
    me = create(:account, :self)
    me.person.update!(address: create(:address))
    me
  end

  entity!(:bank_account) { create(:bank_account, owner: me.person) }

  let(:anonymous) { nil }

  [:admin, :me, :anonymous].each do |user|

    context "user<#{user}>" do

      let(:all) { PersonResource.all(send(user)) }

      it 'all' do
        case user
        when :me
          expect(all.collect { |l| l.object }).to match_array [send(user).person]
        when :admin
          expect(all.collect { |l| l.object }).to match_array Person.all
        else :anonymous
          expect(all.collect { |l| l.object }).to eq []
        end
      end

      it 'retrieve' do
        case user
        when :anonymous
          expect { all.retrieve(me.person.id) }.to raise_error Buzzn::PermissionDenied
        when :admin
          expect(all.retrieve(me.person.id).object).to eq me.person
          expect(all.retrieve(admin.person.id).object).to eq admin.person
        when :me
          expect { all.retrieve(admin.person.id) }.to raise_error Buzzn::PermissionDenied
          expect(all.retrieve(me.person.id).object).to eq me.person
        end
      end

      if user != :anonymous
        it 'update' do
          person = all.retrieve(send(user).person.id)
          expect(person.updatable?).to be true
        end

        it 'delete' do
          person = all.retrieve(send(user).person.id)
          expect(person.deletable?).to be false
        end
      end

      if user == :me
        let(:person) { all.retrieve(me.person.id) }
        context 'address' do
          it 'R-U-D' do
            address = person.address
            expect(address).not_to be_nil
            expect(address.updatable?).to be true
          end
        end

        context 'bank_accounts' do
          it 'R-U-D' do
            bank_accounts = person.bank_accounts
            expect(bank_accounts.collect{|b| b.object}).to eq [bank_account]

            bank_account = bank_accounts.first
            expect(bank_account.updatable?).to be true
          end
        end
      end
    end
  end
end
