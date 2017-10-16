require_relative '../group_resource'
require_relative '../person_resource'
require_relative 'price_resource'
require_relative 'billing_cycle_resource'
require_relative '../../schemas/admin/localpool_incompleteness'
module Admin
  class LocalpoolResource < GroupResource

    model Group::Localpool

    attributes :updatable, :deletable, :incompleteness

    has_one :localpool_processing_contract
    has_one :metering_point_operator_contract
    has_many :meters
    has_many :managers, PersonResource
    has_many :localpool_power_taker_contracts
    has_many :users
    has_many :organizations
    has_many :contracts
    has_many :registers
    has_many :persons
    has_many :prices, PriceResource
    has_many :billing_cycles, BillingCycleResource
    has_one :owner
    has_one :address

    def incompleteness
      LocalpoolIncompleteness.(self).messages
    end

    # API methods for endpoints

    def create_price(params = {})
      create(permissions.prices.create) do
        to_resource(object.prices.create!(params),
                    permissions.prices,
                    PriceResource)
      end
    end

    def create_billing_cycle(params = {})
      create(permissions.billing_cycles.create) do
        to_resource(object.billing_cycles.create!(params),
                    permissions.billing_cycles,
                    BillingCycleResource)
      end
    end

    def create_person_owner(params)
      guarded(permissions.owner.create) do
        Group::Localpool.transaction do
          _assign_owner(to_resource(Person.create!(params),
                                    permissions.owner,
                                    PersonResource))
        end
      end
    end

    def create_organization_owner(params)
      guarded(permissions.owner.create) do
        Group::Localpool.transaction do
          # TODO type safe assignment ?
          _assign_owner(to_resource(Organization.create!(params.merge(mode: :other)),
                                    permissions.owner,
                                    OrganizationResource))
        end
      end
    end

    def assign_owner(new_owner)
      guarded(permissions.owner.update) do
        Group::Localpool.transaction do
          _assign_owner(new_owner)
        end
      end
    end

    def _assign_owner(new_owner)
      old_owner = owner
      case new_owner
      when PersonResource
        object.organization = nil
        object.person = new_owner.object
      when OrganizationResource
        object.person = nil
        object.organization = new_owner.object
      else
        raise "can not handle #{new_owner.class}"
      end
      setup_roles(old_owner, new_owner)
      object.save
      owner
    end
    private :_assign_owner

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
end
