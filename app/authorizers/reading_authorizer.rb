class ReadingAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, register)
    register.updatable_by?(user)
  end

  def readable_by?(user)
    register = resource.register
    if register
      register.readable_by?(user)
    else
      false
    end
  end

  def updatable_by?(user)
    false
  end

  def deletable_by?(user)
    false
  end

end
