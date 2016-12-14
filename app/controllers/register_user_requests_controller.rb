class RegisterUserRequestsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def show
    @register_user_request = RegisterUserRequest.find(params[:id]).decorate
  end

  def create
    register = Register::Base.find(params[:register_id])
    mode = 'request'
    if current_user.can_update?(register)
      current_user.add_role(:member, register)
      register.create_activity key: 'register_user_membership.create', owner: current_user
      flash[:notice] = t('you_were_added_successfully')
    else
      @register_user_request = RegisterUserRequest.new(user: current_user, register: register, mode: mode)
      if @register_user_request.save
        register.create_activity(key: 'register_user_request.create', owner: current_user)
        flash[:notice] = t('sent_register_user_request')
      else
        flash[:error] = t('unable_to_send_register_user_request')
      end
    end
    redirect_to register_path(register)
  end

  def accept
    #byebug
    @register_user_request = RegisterUserRequest.find(params[:id])
    @register = @register_user_request.register
    @mode = @register_user_request.mode
    @user = @register_user_request.user
    if @mode == 'request' && current_user.can_update?(@register) || @mode == 'invitation'
      @register_user_request.accept
      if @register_user_request.save
        @user.add_role(:member, @register)
        @register.create_activity key: 'register_user_membership.create', owner: @user
        flash[:notice] = t('accepted_register_user_request')
        redirect_to register_path(@register)
      end
    else
      flash[:error] = t('unable_to_accept_register_user_request')
      redirect_to register_path(@register)
    end
  end

  def reject
    @register_user_request = RegisterUserRequest.find(params[:id])
    if @register_user_request.mode == 'request' && current_user.can_update?(@register_user_request.register) || @register_user_request.mode == 'invitation'
      @register_user_request.reject
      if @register_user_request.save
        if @register_user_request.mode == 'invitation'
          @register_user_request.register.create_activity(key: 'register_user_invitation.reject', owner: current_user)
          redirect_to profile_path(@register_user_request.user.profile)
          flash[:notice] = t('rejected_register_user_invitation')
        else
          @register_user_request.register.create_activity(key: 'register_user_request.reject', owner: current_user, recipient: @register_user_request.user)
          redirect_to register_path(@register_user_request.register)
          flash[:notice] = t('rejected_register_user_request')
        end
      end
    else
      flash[:error] = t('unable_to_reject_register_user_request')
      redirect_to register_path(@register_user_request.register)
    end
  end


end