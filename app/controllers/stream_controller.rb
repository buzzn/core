class StreamController < ApplicationController

  def index
    if user_signed_in?
      @user_ids             = current_user.friend_ids + [current_user.id]
      @activities           = PublicActivity::Activity
                              .order("created_at desc")
                              .where("owner_id in (?) OR recipient_id in (?)", @user_ids, @user_ids)
                              .where("owner_type = (?) OR recipient_type = (?)", "User", "User")
                              .limit(10)
      @explore_groups       = Group.all.limit(10).decorate
      @explore_profiles     = User.all.where("id NOT IN (?)", current_user.friend_ids + [current_user.id]).limit(10).collect{|u| u.profile.decorate}
    else
      redirect_to new_user_session_path
    end
  end


end