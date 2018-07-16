shared_context "contract entities", :shared_context => :metadata do

    entity(:person) { create(:person, :with_bank_account) }

    entity(:localpool) { create(:group, :localpool, :with_address, owner: person) }

    entity(:organization) do
      buzzn = create(:organization, :with_address)
      buzzn.contact = person
      buzzn.save!
      buzzn
    end
    entity(:bank_account) { create(:bank_account, owner: organization) }

    before do
      $user.person.reload.add_role(Role::GROUP_MEMBER, localpool)
    end

    entity(:metering_point_operator_contract) do
      create(:contract, :metering_point_operator,
             localpool: localpool, contractor_bank_account: bank_account)
    end

    entity(:localpool_power_taker_contract) do
      create(:contract, :localpool_powertaker,
             customer: organization,
             localpool: localpool)
    end

    entity(:localpool_processing_contract) do
      create(:contract, :localpool_processing,
             customer: organization,
             localpool: localpool)
    end

    let('buzzn_json') do
      buzzn = Organization::Market.buzzn
      {
        'id'=>buzzn.id,
        'type'=>'organization_market',
        'updated_at'=>buzzn.updated_at.as_json,
        'name'=>buzzn.name,
        'phone'=>buzzn.phone,
        'fax'=>buzzn.fax,
        'website'=>buzzn.website,
        'email'=>buzzn.email,
        'description'=>buzzn.description,
        'updatable'=>true,
        'deletable'=>false,
        'address'=>{
          'id'=>buzzn.address.id,
          'type'=>'address',
          'updated_at'=>buzzn.address.updated_at.as_json,
          'street'=>buzzn.address.street,
          'city'=>buzzn.address.city,
          'zip'=>buzzn.address.zip,
          'country'=>buzzn.address.attributes['country'],
          'updatable'=>true,
          'deletable'=>false
        }
      }
    end

    let(:person_json) do
      person_json = {
        'id'=>person.id,
        'type'=>'person',
        'updated_at'=>person.updated_at.as_json,
        'prefix'=>person.attributes['prefix'],
        'title'=>person.attributes['title'],
        'first_name'=>person.first_name,
        'last_name'=>person.last_name,
        'phone'=>person.phone,
        'fax'=>person.fax,
        'email'=>person.email,
        'preferred_language'=>person.attributes['preferred_language'],
        'image'=>person.image.medium.url,
        'customer_number' => nil,
        'updatable'=>true,
        'deletable'=>false,
        'address'=>{
          'id'=>person.address.id,
          'type'=>'address',
          'updated_at'=>person.address.updated_at.as_json,
          'street'=>person.address.street,
          'city'=>person.address.city,
          'zip'=>person.address.zip,
          'country'=>person.address.attributes['country'],
          'updatable'=>true,
          'deletable'=>false
        }
      }
      def person_json.dup
        json = super
        json['address'] = json['address'].dup
        json
      end
      person_json
    end

    let(:organization_json) do
      orga_json = {
        'id'=>organization.id,
        'type'=>'organization',
        'updated_at'=>organization.updated_at.as_json,
        'name'=>organization.name,
        'phone'=>organization.phone,
        'fax'=>organization.fax,
        'website'=>organization.website,
        'email'=>organization.email,
        'description'=>organization.description,
        'updatable'=>true,
        'deletable'=>false,
        'customer_number' => nil,
        'address'=>{
          'id'=>organization.address.id,
          'type'=>'address',
          'updated_at'=>organization.address.updated_at.as_json,
          'street'=>organization.address.street,
          'city'=>organization.address.city,
          'zip'=>organization.address.zip,
          'country'=>organization.address.attributes['country'],
          'updatable'=>true,
          'deletable'=>false
        },
        'contact'=>person_json
      }
      def orga_json.dup
        json = super
        json['address'] = json['address'].dup
        json['contact'] = json['contact'].dup
        json
      end
      orga_json
    end

end
