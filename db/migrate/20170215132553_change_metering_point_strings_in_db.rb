class ChangeMeteringPointStringsInDb < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        ActiveRecord::Base.transaction do
          Address.where(addressable_type: 'MeteringPoint').update_all(addressable_type: 'Register::Base')
          PublicActivity::Activity.where(owner_type: 'MeteringPoint').update_all(owner_type: 'Register::Base')
          PublicActivity::Activity.where(recipient_type: 'MeteringPoint').update_all(recipient_type: 'Register::Base')
          Score.where(scoreable_type: 'MeteringPoint').update_all(scoreable_type: 'Register::Base')
          NotificationUnsubscriber.where(trackable_type: 'MeteringPoint').update_all(trackable_type: 'Register::Base')
          Comment.where(commentable_type: 'MeteringPoint').update_all(commentable_type: 'Register::Base')
          PublicActivity::Activity.where(trackable_type: 'MeteringPoint').update_all(trackable_type: 'Register::Base')
        end
      end

      dir.down do
        ActiveRecord::Base.transaction do
          Address.where(addressable_type: 'Register::Base').update_all(addressable_type: 'MeteringPoint')
          PublicActivity::Activity.where(owner_type: 'Register::Base').update_all(owner_type: 'MeteringPoint')
          PublicActivity::Activity.where(recipient_type: 'Register::Base').update_all(recipient_type: 'MeteringPoint')
          Score.where(scoreable_type: 'Register::Base').update_all(scoreable_type: 'MeteringPoint')
          NotificationUnsubscriber.where(trackable_type: 'Register::Base').update_all(trackable_type: 'MeteringPoint')
          Comment.where(commentable_type: 'Register::Base').update_all(commentable_type: 'MeteringPoint')
          PublicActivity::Activity.where(trackable_type: 'Register::Base').update_all(trackable_type: 'MeteringPoint')
        end
      end
    end
  end
end
