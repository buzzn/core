class MigrateContactOfOrganization < ActiveRecord::Migration
  def up
    Organization.all.each do |organization|
      if user = User.users_of(self, :contact).first
        organization.update(contact: user.person)
      end
    end
  end
end
