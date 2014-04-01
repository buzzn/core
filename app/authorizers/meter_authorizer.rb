class MeterAuthorizer < ApplicationAuthorizer

  def self.readable_by?(user)
    true
  end

end