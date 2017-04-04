class ContractingPartyResource

  def self.new(object, *args)
    case object
    when Organization
      FullOrganizationResource.new(object, *args)
    when User
      FullUserResource.new(object, *args)
    else
      raise "can not handle type: #{object.class}"
    end
  end
end
