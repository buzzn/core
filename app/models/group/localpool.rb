module Group
  class Localpool < Base

    has_many :contracts, class_name: Contract::Base, foreign_key: :localpool_id

  end
end
