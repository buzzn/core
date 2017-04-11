class Buzzn::CollectionResource < ActiveModel::Serializer::CollectionSerializer

  def serializer_from_resource(resource, serializer_context_class, options)
    if (resource_class = find_resource_class(resource.class)) &&
       (clazz = "#{resource_class.model}CollectionResource".safe_constantize)
      return clazz.new(resource)
    end
    super
  end

  def find_resource_class(clazz)
    return nil if clazz == Object || clazz.nil?
    const = "#{clazz}Resource".safe_constantize
    if const.nil?
      find_resource_class(clazz.superclass)
    else
      const
    end
  end
  private :find_resource_class
end
