class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true

  scopify

  def self.users_roles_arel_table
    @arel ||= Arel::Table.new(:users_roles)
  end
end
