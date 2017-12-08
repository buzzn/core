module Account
  class Base < ActiveRecord::Base
    self.table_name = :accounts

    belongs_to :person

    def unbound_rolenames
      person.roles.where(resource_id: nil).collect{ |r| r.attributes['name'] }
    end

    def rolename_to_uuids
      @_rolename_to_uuids ||= begin
          person_roles.each_with_object({}) do |r, obj|
          (obj[r.attributes['name']] ||= []) << r.resource_id
        end
      end
    end

    def uuids_to_rolenames
      @_uuids_to_rolenames ||= begin
        person_roles.each_with_object({}) do |r, obj|
          (obj[r.resource_id] ||= []) << r.attributes['name']
        end
      end
    end

    def rolenames_for(uuid)
      unbound_rolenames + uuids_to_rolenames.fetch(uuid, [])
    end

    def uuids_for(rolenames)
      map = rolename_to_uuids
      map.values_at(*(rolenames & map.keys)).flatten
    end

    private

    def person_roles
      person.roles.where('resource_id IS NOT NULL')
    end
  end
end
