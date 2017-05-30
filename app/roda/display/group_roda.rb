class Display::GroupRoda < ::BaseRoda

  include Import.args[:env,
                      'transaction.scores',
                      'transaction.group_charts_ng',
                      'service.current_power']

  plugin :aggregation
  plugin :shared_vars

  route do |r|
    groups = Display::GroupResource.all(current_user)
    r.root do
      groups.filter(r.params['filter'])
    end

    r.on :id do |id|

      group = groups.retrieve(id)
      r.get! do
        group
      end

      r.get! 'charts' do
        aggregated(group_charts_ng.call(r.params, [group.method(:charts)]))
      end

      r.get! 'bubbles' do
        aggregated(group.bubbles)
      end

      r.get! 'mentors' do
        group.mentors
      end

      r.on 'registers' do
        shared[:registers] = group.registers
        r.run ::RegisterRoda
      end

      r.get! 'scores' do
        scores.call(r.params, resource: [group.method(:scores)])
      end
    end
  end
end
