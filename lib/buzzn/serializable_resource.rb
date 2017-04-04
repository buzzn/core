class Buzzn::SerializableResource < ActiveModelSerializers::SerializableResource

  def serializer_instance
    @serializer_instance ||=
      begin
        case resource
        when ActiveModel::Serializer
          resource
        else
          serializer.new(resource, serializer_opts)
        end
      end
  end
end
