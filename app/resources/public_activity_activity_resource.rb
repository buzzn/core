class PublicActivity::ActivitySerializer < ActiveModel::Serializer

  attributes  :owner_id,
              :owner_type,
              :key,
              :recipient_id,
              :recipient_type,
              :created_at
end
