require_relative 'plugins/aggregation'
class GroupRoda < BaseRoda

  include Import.args[:env, 'transaction.group_charts', 'service.current_power']

  plugin :aggregation

  route do |r|
    
    r.on 'localpools' do
      r.run LocalpoolRoda
    end

    r.get! do
      Group::BaseResource.all(current_user, r.params['filter'])
    end

    r.on :id do |id|

      group = Group::BaseResource.retrieve(current_user, id)

      r.get! do
        group
      end

      r.get! 'charts' do
        aggregated(group_charts.call(r.params, group_charts: [group]))
      end

      r.get! 'bubbles' do
        aggregated(current_power.for_each_register_in_group(group))
      end

      # deprecated

      r.get! 'meters' do
        group.meters
      end

      r.get! 'managers' do
        group.managers
      end
    end
  end
end
