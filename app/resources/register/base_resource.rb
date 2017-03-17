module Register
  class BaseSerializer < ActiveModel::Serializer

    attributes  :direction,
                :name,
                :readable

    has_one  :address
    has_one  :meter

  end
end
