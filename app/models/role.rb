# frozen_string_literal: true
class Role < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true

  #scopify

  def self.users_roles_arel_table
    @arel ||= Arel::Table.new(:users_roles)
  end

  BUZZN_OPERATOR = 'BUZZN_OPERATOR'
  GROUP_OWNER = 'GROUP_OWNER'
  GROUP_ADMIN = 'GROUP_ADMIN'
  GROUP_MEMBER = 'GROUP_MEMBER'
  GROUP_ENERGY_MENTOR = 'GROUP_ENERGY_MENTOR'
  SELF = 'SELF'
  CONTRACT = 'CONTRACT'
  ORGANIZATION = 'ORGANIZATION'

  ANONYMOUS = 'ANONYMOUS' # not part of the DB enum !!!!

  enum name: {
         buzzn_operator: BUZZN_OPERATOR,
         group_owner: GROUP_OWNER,
         group_admin: GROUP_ADMIN,
         group_member: GROUP_MEMBER,
         group_energy_mentor: GROUP_ENERGY_MENTOR,
         self: SELF,
         contract: CONTRACT,
         organization: ORGANIZATION
       }
  ROLES_DB = [BUZZN_OPERATOR,
              GROUP_OWNER,
              GROUP_ADMIN,
              GROUP_MEMBER,
              GROUP_ENERGY_MENTOR,
              SELF,
              CONTRACT,
              ORGANIZATION].freeze
  ROLES = (ROLES_DB + [ANONYMOUS]).freeze
end
