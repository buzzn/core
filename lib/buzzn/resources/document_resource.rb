class DocumentResource < Buzzn::Resource::Entity

  model Document

  attributes :filename,
             :size,
             :mime,
             :sha256,
             :purpose

  attributes :deletable
  attributes :created_at

end
