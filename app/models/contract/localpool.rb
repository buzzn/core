module Contract
  class Localpool < Base
    belongs_to :localpool, class_name: Group::Localpool

    # permissions helpers

    scope :permitted, ->(uuids) { where(id: uuids) }

  end
end
