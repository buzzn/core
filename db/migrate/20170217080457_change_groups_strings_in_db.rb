class ChangeGroupsStringsInDb < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        ActiveRecord::Base.transaction do
          Address.where(addressable_type: 'Group').update_all(addressable_type: 'Group::Base')
#          PublicActivity::Activity.where(owner_type: 'Group').update_all(owner_type: 'Group::Base')
 #         PublicActivity::Activity.where(recipient_type: 'Group').update_all(recipient_type: 'Group::Base')
          Score.where(scoreable_type: 'Group').update_all(scoreable_type: 'Group::Base')
#          NotificationUnsubscriber.where(trackable_type: 'Group').update_all(trackable_type: 'Group::Base')
          Comment.where(commentable_type: 'Group').update_all(commentable_type: 'Group::Base')
  #        PublicActivity::Activity.where(trackable_type: 'Group').update_all(trackable_type: 'Group::Base')
        end
      end

      dir.down do
        ActiveRecord::Base.transaction do
          Address.where(addressable_type: 'Group::Base').update_all(addressable_type: 'Group')
   #       PublicActivity::Activity.where(owner_type: 'Group::Base').update_all(owner_type: 'Group')
    #      PublicActivity::Activity.where(recipient_type: 'Group::Base').update_all(recipient_type: 'Group')
          Score.where(scoreable_type: 'Group::Base').update_all(scoreable_type: 'Group')
 #         NotificationUnsubscriber.where(trackable_type: 'Group::Base').update_all(trackable_type: 'Group')
          Comment.where(commentable_type: 'Group::Base').update_all(commentable_type: 'Group')
     #     PublicActivity::Activity.where(trackable_type: 'Group::Base').update_all(trackable_type: 'Group')
        end
      end
    end
  end
end
