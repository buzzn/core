describe "#{Buzzn::Permission} - #{PersonResource}" do

  entity(:admin) { Fabricate(:admin) }
  entity!(:me) do
    me = Fabricate(:user)
    me.person.address = Fabricate(:address)
    me.person.save
    me
  end

  entity!(:bank_account) { Fabricate(:bank_account,
                                     contracting_party: me.person) }

  let(:anonymous) { nil }

  [:admin, :me, :anonymous].each do |user|
    
    context "user<#{user}>" do

      let(:all) { PersonResource.all(send(user)) }

      it "all" do
        if user != :anonymous
          expect(all.collect { |l| l.object }).to match_array [send(user).person]
        else
          expect(all.collect { |l| l.object }).to eq []
        end
      end

      it "retrieve" do
        case user
        when :anonymous
          expect { all.retrieve(me.person.id) }.to raise_error Buzzn::PermissionDenied
        when :admin
          expect { all.retrieve(me.person.id) }.to raise_error Buzzn::PermissionDenied
          expect(all.retrieve(admin.person.id).object).to eq admin.person
        when :me
          expect { all.retrieve(admin.person.id) }.to raise_error Buzzn::PermissionDenied
          expect(all.retrieve(me.person.id).object).to eq me.person          
        end
      end

      if user != :anonymous
        it 'update' do
          person = all.retrieve(send(user).person.id)
          expect { person.update(updated_at: person.object.updated_at) }.not_to raise_error
        end

        it 'delete' do
          expect { all.retrieve(me.person.id).delete }.to raise_error Buzzn::PermissionDenied
        end
      end

      if user == :me
        let(:person) { all.retrieve(me.person.id) }
        context 'address' do
          it 'R-U-D' do
            address = person.address
            expect(address).not_to be_nil

            expect { address.update({updated_at: address.object.updated_at}) }.not_to raise_error

            person.object.address = nil
            person.object.save
            expect(person.object.reload.address).to be_nil
          end
        end

        context 'bank_accounts' do
          it 'R-U-D' do
            bank_accounts = person.bank_accounts
            expect(bank_accounts.collect{|b| b.object}).to eq [bank_account]

            bank_account = bank_accounts.first
            expect { bank_account .update({updated_at: bank_account .object.updated_at}) }.not_to raise_error

            bank_account.delete
            expect(person.object.reload.bank_accounts.size).to eq 0
          end
        end
      end
    end
  end
end
