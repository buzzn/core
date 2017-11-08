require_relative '../localpool'

class Transactions::Admin::Localpool::AssignOwnerBase < Transactions::Base

  def assign_owner(localpool, new_owner)
    old_owner = localpool.owner
    localpool.object.owner = new_owner.object
    setup_roles(old_owner, new_owner)
    localpool.object.save
    localpool.owner
  end

  def setup_roles(old_owner, new_owner)
    # remove GROUP_OWNER from old
    case old_owner
    when PersonResource
      old_owner.object.remove_role(Role::GROUP_OWNER, object)
    when OrganizationResource
      setup_roles(old_owner.legal_representation, nil)
    when NilClass
    # skip
    else
      raise "can not handle #{old_owner.class}"
    end

    # add GROUP_OWNER to new
    case new_owner
    when PersonResource
      new_owner.object.add_role(Role::GROUP_OWNER, object)
    when OrganizationResource
      setup_roles(nil, new_owner.legal_representation)
    when NilClass
    # skip
    else
      raise "can not handle #{new_owner.class}"
    end
  end
end
