class ChangePublicActivityMeteringPointStringsInDb < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        ActiveRecord::Base.transaction do
          PublicActivity::Activity.where(key: 'user.appointed_metering_point_manager').update_all(key: 'user.appointed_register_manager')
          PublicActivity::Activity.where(key: 'group_metering_point_membership.create').update_all(key: 'group_register_membership.create', trackable_type: 'GroupRegisterRequest')
          PublicActivity::Activity.where(key: 'group_metering_point_request.create').update_all(key: 'group_register_request.create', trackable_type: 'GroupRegisterRequest')
          PublicActivity::Activity.where(key: 'group_metering_point_request.update').update_all(key: 'group_register_request.update', trackable_type: 'GroupRegisterRequest')
          PublicActivity::Activity.where(key: 'metering_point_user_request.create').update_all(key: 'register_user_request.create', trackable_type: 'RegisterUserRequest')
          PublicActivity::Activity.where(key: 'metering_point_user_request.update').update_all(key: 'register_user_request.update', trackable_type: 'RegisterUserRequest')
          PublicActivity::Activity.where(key: 'metering_point_user_request.destroy').update_all(key: 'register_user_request.destroy', trackable_type: 'RegisterUserRequest')
          PublicActivity::Activity.where(key: 'group_metering_point_request.destroy').update_all(key: 'group_register_request.destroy', trackable_type: 'GroupRegisterRequest')
          PublicActivity::Activity.where(key: 'group_metering_point_invitation.create').update_all(key: 'group_register_invitation.create')
          PublicActivity::Activity.where(key: 'group_metering_point_membership.cancel').update_all(key: 'group_register_membership.cancel')
        end
      end

      dir.down do
        ActiveRecord::Base.transaction do
          PublicActivity::Activity.where(key: 'user.appointed_register_manager').update_all(key: 'user.appointed_metering_point_manager')
          PublicActivity::Activity.where(key: 'group_register_membership.create').update_all(key: 'group_metering_point_membership.create', trackable_type: 'GroupMeteringPointRequest')
          PublicActivity::Activity.where(key: 'group_register_request.create').update_all(key: 'group_metering_point_request.create', trackable_type: 'GroupMeteringPointRequest')
          PublicActivity::Activity.where(key: 'group_register_request.update').update_all(key: 'group_metering_point_request.update', trackable_type: 'GroupMeteringPointRequest')
          PublicActivity::Activity.where(key: 'register_user_request.create').update_all(key: 'metering_point_user_request.create', trackable_type: 'MeteringPointUserRequest')
          PublicActivity::Activity.where(key: 'register_user_request.update').update_all(key: 'metering_point_user_request.update', trackable_type: 'MeteringPointUserRequest')
          PublicActivity::Activity.where(key: 'register_user_request.destroy').update_all(key: 'metering_point_user_request.destroy', trackable_type: 'MeteringPointUserRequest')
          PublicActivity::Activity.where(key: 'group_register_request.destroy').update_all(key: 'group_metering_point_request.destroy', trackable_type: 'GroupMeteringPointRequest')
          PublicActivity::Activity.where(key: 'group_register_invitation.create').update_all(key: 'group_metering_point_invitation.create')
          PublicActivity::Activity.where(key: 'group_register_membership.cancel').update_all(key: 'group_metering_point_membership.cancel')
        end
      end
    end
  end
end
