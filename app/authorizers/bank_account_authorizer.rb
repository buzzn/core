class BankAccountAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user, parent)
    parent.updatable_by?(user)
  end

  def readable_by?(user)
    # uses scope BankAccount.readable_by(user)
    readable?(BankAccount, user)
  end

  def updatable_by?(user)
    resource.bank_accountable.updatable_by?(user)
  end

  def deletable_by?(user)
    resource.bank_accountable.updatable_by?(user)
  end

end
