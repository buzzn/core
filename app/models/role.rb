class Role < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true

  scopify

  def self.users_roles_arel_table
    @arel ||= Arel::Table.new(:users_roles)
  end
end
