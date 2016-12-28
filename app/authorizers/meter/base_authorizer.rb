class Meter::BaseAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
    !!user
  end

  def readable_by?(user)
    # uses scope Meter::Base.readable_by(user)
    readable?(Meter::Base, user)
  end

  def updatable_by?(user)
    readable_by?(user)
  end

  def deletable_by?(user)
    readable_by?(user)
  end

end
