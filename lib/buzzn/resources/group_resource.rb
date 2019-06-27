class GroupResource < Buzzn::Resource::Entity
  require_relative 'admin/comment_resource'

  model Group::Base

  attributes  :name,
              :slug,
              :description

  has_many :comments, Admin::CommentResource

  def type
    case object
    when Group::Tribe
      'group_tribe'
    when Group::Localpool
      'group_localpool'
    else
      raise "unknown group type: #{object.class}"
    end
  end

end
