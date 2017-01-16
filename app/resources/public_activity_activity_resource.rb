class PublicActivity::ActivityResource < JSONAPI::Resource
  abstract

  attributes  :owner_id,
              :owner_type,
              :key,
              :recipient_id,
              :recipient_type,
              :created_at
end
