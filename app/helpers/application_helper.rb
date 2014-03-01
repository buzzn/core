module ApplicationHelper

  def policy(record)
    "#{record.class}Policy".constantize.new(current_user, record)
  end

end
