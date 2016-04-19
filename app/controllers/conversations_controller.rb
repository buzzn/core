class ConversationsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def new
    @conversation = Conversation.new
    authorize_action_for(@conversation)
  end

  def create
    @conversation = Conversation.create
    authorize_action_for(@conversation)
    if params[:user_ids].any?
      params[:user_ids].each do |user_id|
        User.find(user_id).add_role(:member, @conversation)
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
    @conversation.users.each do |user|
      if !params[:user_ids].include?(user.id)
        user.remove_role(:member, @conversation)
      end
    end
    if params[:user_ids].any?
      params[:user_ids].each do |user_id|
        User.find(user_id).add_role(:member, @conversation)
      end
    end
  end


end