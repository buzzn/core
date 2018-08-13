shared_context 'contract entities', :shared_context => :metadata do

  let(:person) { create(:person, :with_bank_account) }

  let(:person2) { create(:person, :with_bank_account) }

  let(:organization) do
    org = create(:organization, :with_address, :with_legal_representation)
    org.contact = person
    org.save!
    org
  end
  let!(:bank_account) { create(:bank_account, owner: organization) }
  let(:localpool) { create(:group, :localpool, :with_address, owner: organization) }

  before do
    $user.person.reload.add_role(Role::GROUP_MEMBER, localpool)
  end

  let(:metering_point_operator_contract) do
    create(:contract, :metering_point_operator,
           localpool: localpool,
           contractor_bank_account: bank_account)
  end

  let(:localpool_power_taker_contract) do
    create(:contract, :localpool_powertaker,
           contractor: localpool.owner,
           customer: person2,
           localpool: localpool)
  end

  let(:localpool_processing_contract) do
    create(:contract, :localpool_processing,
           customer: localpool.owner,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  let('buzzn_json') do
    buzzn = Organization::Market.buzzn
    {
      'id'=>buzzn.id,
      'type'=>'organization_market',
      'created_at'=>buzzn.created_at.as_json,
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
        'created_at'=>buzzn.address.created_at.as_json,
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
      'created_at'=>person.created_at.as_json,
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
        'created_at'=>person.address.created_at.as_json,
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

  let(:person2_json) do
    person2_json = {
      'id'=>person2.id,
      'type'=>'person',
      'created_at'=>person2.created_at.as_json,
      'updated_at'=>person2.updated_at.as_json,
      'prefix'=>person2.attributes['prefix'],
      'title'=>person2.attributes['title'],
      'first_name'=>person2.first_name,
      'last_name'=>person2.last_name,
      'phone'=>person2.phone,
      'fax'=>person2.fax,
      'email'=>person2.email,
      'preferred_language'=>person2.attributes['preferred_language'],
      'image'=>person2.image.medium.url,
      'customer_number' => nil,
      'updatable'=>true,
      'deletable'=>false,
      'address'=>{
        'id'=>person2.address.id,
        'type'=>'address',
        'created_at'=>person2.address.created_at.as_json,
        'updated_at'=>person2.address.updated_at.as_json,
        'street'=>person2.address.street,
        'city'=>person2.address.city,
        'zip'=>person2.address.zip,
        'country'=>person2.address.attributes['country'],
        'updatable'=>true,
        'deletable'=>false
      }
    }
    def person2_json.dup
      json = super
      json['address'] = json['address'].dup
      json
    end
    person2_json
  end

  let(:organization_json) do
    orga_json = {
      'id'=>organization.id,
      'type'=>'organization',
      'created_at'=>organization.created_at.as_json,
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
        'created_at'=>organization.address.created_at.as_json,
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
