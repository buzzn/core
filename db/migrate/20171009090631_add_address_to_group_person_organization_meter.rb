class AddAddressToGroupPersonOrganizationMeter < ActiveRecord::Migration
  def change
    add_belongs_to :groups, :address, index: true, type: :uuid, null: true
    add_foreign_key :groups, :addresses, name: :fk_groups_address

    add_belongs_to :meters, :address, index: true, type: :uuid, null: true
    add_foreign_key :meters, :addresses, name: :fk_meters_address

    org = Organization.all.each_with_object({}) do |o, map|
      address = Address.where(addressable_id: o.id).first
      map[o.id] = address if address
    end

    per = Person.all.each_with_object({}) do |o, map|
      address = Address.where(addressable_id: o.id).first
      map[o.id] = address if address
    end

    reg = Register::Base.all.each_with_object({}) do |o, map|
      address = Address.where(addressable_id: o.id).first
      map[o.meter.id] = address if address
    end

    add_belongs_to :persons, :address, index: true, type: :uuid, null: true
    add_foreign_key :persons, :addresses, name: :fk_persons_address


    add_belongs_to :organizations, :address, index: true, type: :uuid, null: true
    add_foreign_key :organizations, :addresses, name: :fk_organizations_address

    Organization.reset_column_information
    Person.reset_column_information
    Meter::Base.reset_column_information

    org.each do |id, address|
      Organization.find(id).update(address: address)
    end
    per.each do |id, address|
      Person.find(id).update(address: address)
    end
    reg.each do |id, address|
      Meter::Base.find(id).update(address: address)
    end

    # remove duplicates
    Address.where('id not in (?)', reg.values + per.values + org.values).each do |a|
      next unless a.addressable_type == 'Register::Base'
      other = a.addressable.meter.address
      if other && other.street == a.street && other.zip == a.zip
        a.delete
      end
    end

    if Address.count == (reg.values + per.values + org.values).size
      remove_column :addresses, :addressable_id
      remove_column :addresses, :addressable_type
    else
      raise 'there are unmoved Addresses - aborting'
    end
  end
end
