ActiveModel::Serializer.setup do |config|
  config.embed    = :ids
  config.adapter  = :json_api
end