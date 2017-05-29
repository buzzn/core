require_relative 'plugins/aggregation'
class GroupRoda < BaseRoda

  include Import.args[:env,
                      'transaction.scores',
                      'transaction.group_charts',
                      'service.current_power']

  plugin :aggregation
  plugin :shared_vars

  route do |r|
    
    r.on 'localpools' do
      r.run LocalpoolRoda
    end

    groups = Group::BaseResource.all(current_user)
    r.root do
      # TODO use: groups.filter(r.params['filter'])
      Group::BaseResource.all(current_user, r.params['filter'])
    end

    r.on :id do |id|

      # TODO use: group = groups.retrieve(id)
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

      r.get! 'mentors' do
        group.object.managers[0..1].collect do |m|
          MentorResource.new(m)
        end
      end

      r.on 'registers' do
        shared[:registers] = group.registers.consumption_production
        r.run RegisterRoda
      end

      r.get! 'scores' do
        scores.call(r.params, resource: [group.method(:scores)])
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
