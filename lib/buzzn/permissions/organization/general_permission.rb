require_relative '../../permission'

module Organization

  GeneralResource::Permission = Buzzn::Permission.new(GeneralResource) do
    # define groups of roles
    define_group(:buzzn_operator, Role::BUZZN_OPERATOR)

    # top level CRUD permissions
    retrieve :buzzn_operator

    # nested method and its CRUD permissions, missing ones means no permissions
    address do
      retrieve :buzzn_operator
    end

    contact do
      retrieve :buzzn_operator
      address do
        retrieve :buzzn_operator
      end
    end

    legal_representation do
      retrieve :buzzn_operator
    end
  end

end
