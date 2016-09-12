class ScoreAuthorizer < ApplicationAuthorizer

  def readable_by?(user)
    # uses scope Score.readable_by(user)
    readable?(Score, user)
  end

end
