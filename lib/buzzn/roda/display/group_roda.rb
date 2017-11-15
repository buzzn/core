require_relative '../display_roda'
require_relative '../../transactions/bubbles'
require_relative '../../transactions/group_chart'
require_relative '../../transactions/display/score'

class Display::GroupRoda < BaseRoda
  plugin :aggregation
  plugin :shared_vars

  route do |r|
    groups = Display::GroupResource.all(current_user)
    r.root do
      groups.filter(r.params['filter'])
    end

    r.on :id do |id|

      group = groups.retrieve_with_slug(id)
      r.get! do
        group
      end

      r.get! 'charts' do
        aggregated(
          Transactions::GroupChart
            .for(group)
            .call(r.params).value
        )
      end

      r.get! 'bubbles' do
        aggregated(
          Transactions::Bubbles
            .call(group).value
        )
      end

      r.get! 'mentors' do
        group.mentors
      end

      r.on 'registers' do
        shared[:registers] = group.registers
        r.run ::RegisterRoda
      end

      r.get! 'scores' do
        Transactions::Display::Score
          .for(group)
          .call(r.params)
      end
    end
  end
end
