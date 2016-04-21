class ConversationsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js, :json

  def new
    @conversation = Conversation.new
    authorize_action_for(@conversation)
  end

  def create
    @conversation = Conversation.create
    authorize_action_for(@conversation)
    user_ids = params[:conversation][:user_ids].reject{|id| id.empty?} + [current_user.id]
    if user_ids.any?
      user_ids.each do |user_id|
        User.find(user_id).add_role(:member, @conversation)
        #TODO: create activity and notify users
      end
    end
  end

  def index
    if user_signed_in?
      @conversations = Conversation.with_user(current_user)
    end
  end

  def edit
    @conversation = Conversation.find(params[:id])
    authorize_action_for(@conversation)
  end


  def update
    @conversation = Conversation.find(params[:id])
    authorize_action_for @conversation
    user_ids = params[:conversation][:user_ids].reject{|id| id.empty?} + [current_user.id]
    @conversation.users.each do |user|
      if !user_ids.include?(user.id)
        user.remove_role(:member, @conversation)
        #TODO: create activity and notify users
      end
    end
    if user_ids.any?
      user_ids.each do |user_id|
        User.find(user_id).add_role(:member, @conversation)
        #TODO: create activity and notify users
      end
    end
  end

  def unsubscribe
    @conversation = Conversation.find(params[:id])
    authorize_action_for(@conversation)
    current_user.remove_role(:member, @conversation)
    #TODO: create activity and notify users
  end
  authority_actions :unsubscribe => 'update'

  # private
  # def conversation_params
  #   params.require(:conversation).permit())
  # end


end