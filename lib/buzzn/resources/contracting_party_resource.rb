class ContractingPartyResource

  def self.new(object, *args)
    case object
    when Organization
      ContractingPartyOrganizationResource.new(object, *args)
    when User
      ContractingPartyUserResource.new(object, *args)
    else
      raise "can not handle type: #{object.class}"
    end
  end
end
