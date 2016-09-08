class JSONAPI::ResourceSerializer

private

  def link_object_to_one(source, relationship, include_linkage)
    include_linkage = include_linkage | @always_include_to_one_linkage_data | relationship.always_include_linkage_data
    link_object_hash = {}
    link_object_hash[:links] = {}
    # link_object_hash[:links][:self] = self_link(source, relationship)
    link_object_hash[:links][:related] = related_link(source, relationship)
    link_object_hash[:data] = to_one_linkage(source, relationship) if include_linkage
    link_object_hash
  end

  def link_object_to_many(source, relationship, include_linkage)
    include_linkage = include_linkage | relationship.always_include_linkage_data
    link_object_hash = {}
    link_object_hash[:links] = {}
    # link_object_hash[:links][:self] = self_link(source, relationship)
    link_object_hash[:links][:related] = related_link(source, relationship)
    link_object_hash[:data] = to_many_linkage(source, relationship) if include_linkage
    link_object_hash
  end

end
