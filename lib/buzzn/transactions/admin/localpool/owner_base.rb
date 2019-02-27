require_relative '../localpool'

class Transactions::Admin::Localpool::OwnerBase < Transactions::Base

  def old_owner(resource:, params:, **)
    resource.owner
  end

  def assign_owner(new_owner:, resource:, **)
    old_owner = resource.owner
    resource.object.owner = new_owner&.object
    setup_roles(resource, old_owner, new_owner)
    resource.object.save!
    resource.owner
  end

  def setup_new_roles(resource:, old_owner:, new_owner:, params:, **)
    setup_roles(resource, old_owner, new_owner)
    resource.object.save!
    resource.owner
  end

  private

  def setup_roles(localpool, old_owner, new_owner)
    # remove GROUP_OWNER from old
    case old_owner
    when PersonResource
      old_owner.object.remove_role(Role::GROUP_OWNER, localpool.object)
    when Organization::GeneralResource
      setup_roles(localpool, old_owner.contact, nil)
    when NilClass
    # skip
    else
      raise "can not handle #{old_owner.class}"
    end

    # add GROUP_OWNER to new
    case new_owner
    when PersonResource
      new_owner.object.add_role(Role::GROUP_OWNER, localpool.object)
    when Organization::GeneralResource
      setup_roles(localpool, nil, new_owner.contact)
    when NilClass
    # skip
    else
      raise "can not handle #{new_owner.class}"
    end
  end
  private :setup_roles

end
