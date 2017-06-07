# TODO get rid of this Serializer
class BankSerializer < ActiveModel::Serializer
  attributes  :blz,
              :bic,
              :description,
              :zip,
              :place,
              :name
end
