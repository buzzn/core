class ContractingPartyResource

  def self.new(object, *args)
    case object
    when Organization
      ContractingPartyOrganizationSingleResource.new(object, *args)
    when User
      ContractingPartyUserSingleResource.new(object, *args)
    else
      raise "can not handle type: #{object.class}"
    end
  end
end
