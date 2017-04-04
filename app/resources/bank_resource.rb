class BankSerializer < ActiveModel::Serializer
  attributes  :blz,
              :bic,
              :description,
              :zip,
              :place,
              :name
end
