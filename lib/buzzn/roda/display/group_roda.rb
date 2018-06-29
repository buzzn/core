require_relative '../display_roda'

class Display::GroupRoda < BaseRoda

  include Import.args[:env,
                      'transactions.display.daily_charts',
                      'transactions.bubbles']

  plugin :aggregation

  route do |r|
    groups = Display::GroupResource.all(current_user)
    r.root do
      groups
    end

    r.on :id do |id|

      group = groups.retrieve_with_slug(id)

      unless group.object.show_display_app
        request.halt([403, {'Content-Type' => 'application/json'}, ['{}']])
      end

      r.get! do
        group
      end

      r.get! 'charts' do
        aggregated(daily_charts.(group).value!)
      end

      r.get! 'bubbles' do
        aggregated(bubbles.(group).value!)
      end

      r.get! 'mentors' do
        group.mentors
      end
    end
  end

end
