module Contract
  class Localpool < Base
    belongs_to :localpool, class_name: Group::Localpool

    # permissions helpers

    scope :restricted, ->(uuids) { where(id: uuids) }

  end
end
