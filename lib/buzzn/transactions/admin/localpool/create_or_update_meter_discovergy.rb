require_relative '../localpool'

class Transactions::Admin::Localpool::CreateOrUpdateMeterDiscovergy < Transactions::Base

  authorize :allowed_roles
  add :optimized_group_srv
  add :change_is_necessary
  add :update
  map :wrap_up

  def allowed_roles(permission_context:)
    permission_context.meters.update
  end

  def optimized_group_srv
    Import.global('services.datasource.discovergy.optimized_group')
  end

  def change_is_necessary(resource:, params:, optimized_group_srv:)
    !optimized_group_srv.verify(resource.object)
  end

  def update(change_is_necessary:, resource:, optimized_group_srv:, **)
    if change_is_necessary
      optimized_group_srv.update(resource.object)
    end
    resource.object.meters_discovergy.order(:created_at).last
  end

  def wrap_up(resource:, update:, **)
    resource.object.reload
    if update.nil?
      raise Buzzn::RecordNotFound
    else
      Meter::DiscovergyResource.new(
        resource.object.meters_discovergy.order(:created_at).last
      )
    end
  end

end
