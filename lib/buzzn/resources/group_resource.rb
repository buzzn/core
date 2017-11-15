class GroupResource < Buzzn::Resource::Entity
  include Import.reader['service.current_power',
                        'service.charts']

  abstract

  model Group::Base

  attributes  :name,
              :slug,
              :description

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
