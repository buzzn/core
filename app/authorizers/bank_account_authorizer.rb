class BankAccountAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    !!user
  end

  def readable_by?(user)
    User.admin?(user)
  end

  def updatable_by?(user)
    User.admin?(user)
  end

  def deletable_by?(user)    
    User.admin?(user)
  end

end
