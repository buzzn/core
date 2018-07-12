require_relative '../../permission'

module Organization

  GeneralResource::Permission = Buzzn::Permission.new(GeneralResource) do
    # define groups of roles
    define_group(:ops, Role::BUZZN_OPERATOR)

    # top level CRUD permissions
    retrieve :ops

    # nested method and its CRUD permissions, missing ones means no permissions
    address do
      retrieve :ops
    end

    contact do
      retrieve :ops
      address do
        retrieve :ops
      end
    end

    legal_representation do
      retrieve :ops
    end
  end

end
