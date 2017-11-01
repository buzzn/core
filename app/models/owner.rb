module Owner

  def self.included(model)
    model.belongs_to :owner_person, class_name: 'Person', foreign_key: :owner_person_id
    model.belongs_to :owner_organization, class_name: 'Organization', foreign_key: :owner_organization_id
  end

  def owner
    (owner_organization_id && owner_organization) || (owner_person_id && owner_person)
  end

  def owner=(new_owner)
    case new_owner
    when Person
      self.owner_person = new_owner
      self.owner_organization = nil
    when Organization
      self.owner_organization = new_owner
      self.owner_person = nil
    when NilClass
      # allow nil
      self.owner_organization = nil
      self.owner_person = nil
    else
      raise "Can't assign #{new_owner.inspect} as owner, not a Person or Organization."
    end
  end
end
