module Account
  class Base < ActiveRecord::Base
    self.table_name = :accounts

    belongs_to :person

    def unbound_rolenames
      person.roles.where(resource_id: nil).collect{ |r| r.attributes['name'] }
    end

    def rolename_to_uuids
      person.roles.where('resource_id IS NOT NULL').each_with_object({}) do |r, obj|
        (obj[r.attributes['name']] ||= []) << r.resource_id
      end
    end

    def uuids_to_rolenames
      person.roles.where('resource_id IS NOT NULL').each_with_object({}) do |r, obj|
        (obj[r.resource_id] ||= []) << r.attributes['name']
      end
    end

    def rolenames_for(uuid)
      unbound_rolenames + uuids_to_rolenames.fetch(uuid, [])
    end

    def uuids_for(rolenames)
      map = rolename_to_uuids
      map.values_at(*(rolenames & map.keys)).flatten
    end
  end
end
