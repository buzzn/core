module Contract
  class Localpool < Base
    belongs_to :localpool, class_name: Group::Localpool
  end
end
