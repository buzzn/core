module Account
  class Base < ActiveRecord::Base

    self.table_name = :accounts

    belongs_to :person, dependent: :destroy

    before_destroy :destroy_related

    # Sequel foreign_key does not work
    def destroy_related
      Account::PasswordHash.all.to_a.keep_if { |x| x.account == self }.collect { |x| x.destroy }
      Account::PasswordResetKey.all.to_a.keep_if { |x| x.account == self }.collect { |x| x.destroy }
      Account::LoginChangeKey.all.to_a.keep_if { |x| x.account == self }.collect { |x| x.destroy }
    end

    def unbound_rolenames
      @unbound_rolenames ||= person.roles.where(resource_id: nil).collect { |r| r.attributes['name'] }
    end

    def uids_to_rolenames
      @_uids_to_rolenames ||= begin
        person_roles.each_with_object({}) do |r, obj|
          (obj[uid(r)] ||= []) << r.attributes['name']
        end
      end
    end

    def uids_for(rolenames)
      map = rolename_to_uids
      map.values_at(*(rolenames & map.keys)).flatten
    end

    private

    def uid(resource)
      "#{resource.resource_type}:#{resource.resource_id}"
    end

    def rolename_to_uids
      @_rolename_to_uids ||= begin
        person_roles.each_with_object({}) do |r, obj|
          (obj[r.attributes['name']] ||= []) << uid(r)
        end
      end
    end

    def person_roles
      person.roles.where('resource_id IS NOT NULL')
    end

  end
end
