module Buzzn

  class Roles

    def initialize(parent, role)
      raise 'protected constractor called' if self.class == Roles
      @parent = parent
      @role = role
      @participants = User.users_of(@parent, @role)
    end

    def method_missing(method, *args, &block)
      if @participants.respond_to?(method)
        @participants.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to?(method, options = {})
      @roles.respond_to?(method) || super
    end

    def check_updatable(current_user, user, options)
      unless @parent.updatable_by?(*[current_user, options[:update]].compact) || current_user == user
        raise PermissionDenied.new
      end
    end
    private :check_updatable
    
    def include?(user)
      User.users_of(@parent, @role).where(id: user).limit(1).size == 1
    end
    alias :member? :include?

    def replace(current_user, user_ids, options = {})
      check_updatable(current_user, nil, options)
      User.transaction do
        replace_users(user_ids, @participants.collect { |i| i }, options)
      end
    end
    alias :'=' :replace

    def replace_users(ids, old_ones, options)
      new_ones = User.where(id: ids)
      (old_ones - new_ones).each do |user|
        do_delete_without_check(user, options)
      end
      (new_ones - old_ones).each do |user|
        do_add(user, options)
      end
      @participants = User.users_of(@parent, @role)
    end
    private :replace_users

    def delete(current_user, user, options = {})
      check_updatable(current_user, user, options)
      User.transaction do
        do_delete(user, options)
      end
    end
    alias :remove :delete

    def do_delete_without_check(user, options)
      user.remove_role(@role, @parent)
      if options[:cancel_key]
        if options[:owner]
          PublicActivity::Activity.create(trackable: user,
                                          key: options[:cancel_key],
                                          owner: options[:owner],
                                          recipient: @parent)
        else
          PublicActivity::Activity.create(trackable: @parent, key: options[:cancel_key], owner: user)
        end
      end
      @participants = User.users_of(@parent, @role)
    end

    def do_delete(user, options)
      do_delete_without_check(user, options)
    end
    private :do_delete, :do_delete_without_check

    def add(current_user, user, options = {})
      check_updatable(current_user, user, options)
      User.transaction do
        do_add(user, options)
      end
    end
    alias :<< :add               
  
    def do_add(user, options)
      user.add_role(@role, @parent)
      if options[:create_key]
        if options[:owner]
          PublicActivity::Activity.create(trackable: user,
                                          key: options[:create_key],
                                          owner: options[:owner],
                                          recipient: @parent)
        else
          PublicActivity::Activity.create(trackable: @parent, key: options[:create_key], owner: user)
        end
      end
      @participants = User.users_of(@parent, @role)
    end
    private :do_add

    def to_a
      @participants
    end
    alias :to_ary :to_a
  end
  
  class Managers < Roles
    def initialize(parent)
      super(parent, :manager)
    end

    def do_delete(user, options)
      super
      ensure_at_least_one_manager
    end

    def replace_users(ids, old_ones, options = {})
      super
      ensure_at_least_one_manager
    end

    private
    def ensure_at_least_one_manager
      if @participants.size == 0
        raise ArgumentError.new "#{@parent.class} needs to have at least one manager"
      end
    end
  end

  class Members < Roles
    def initialize(parent)
      super(parent, :member)
    end
  end

  module ManagerRole
    def managers
      @managers ||= Managers.new(self)
    end

    def manager?(user)
      managers.include?(user)
    end

    class CreateMethod
      def guarded_create_with_manager(user, params)
        transaction do
          result = old_guarded_create(user, params)
          user.add_role(result, :manager)
          result
        end
      end
    end

    def included(model)
      model.extend CreateMethod
      model.class_eval do
        alias :old_guarded_create :guarded_create
      end
    end
  end

  module MemberRole
    def members
      @members ||= Members.new(self)
    end

    def member?(user)
      member.include?(user)
    end
  end

end
