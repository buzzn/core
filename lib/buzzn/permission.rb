require 'dry/core/inflector'

module Buzzn
  class Permission

    attr_reader :name

    def initialize(name, parent = nil, &block)
      if parent
        @parent = parent
        @name = name
      else
        @name = Dry::Core::Inflector.underscore(name.to_s.sub('Resource', '').sub('::', '_')).downcase.to_sym
      end

      @perms = {}
      @groups = {}
      instance_eval &block
      freeze unless @parent
    end

    def freeze
      @groups.freeze
      @perms.freeze
      @perms.each do |k, v|
        v.freeze
      end
    end

    def dup(name)
      permission = super()
      permission.instance_variable_set(:@name, name)
      permission.instance_variable_set(:@perms, @perms.dup)
      permission
    end

    def root
      @parent ? @parent.root : self
    end

    def define_group(name, *args)
      @groups[name] = args.freeze
    end

    def get(name)
      @groups[name] || (@parent ? @parent.get(name) : raise("group not found: #{name}"))
    end

    [:create, :retrieve, :update, :document, :delete].each do |method|
      define_method method do |group_name = nil|
        if group_name
          @perms[method] = get(group_name)
        else
          @perms[method] || []
        end
      end
    end

    def crud(group_name)
      create(group_name)
      retrieve(group_name)
      update(group_name)
      document(group_name)
      delete(group_name)
    end

    def [](*path)
      remainder = path[1..-1]
      if remainder.empty?
        @perms[path[0].to_sym]
      else
        node = @perms[path[0].to_sym]
        raise "missing reference #{path[0]} in #{self}" unless node
        node[*remainder]
      end
    end

    def child(name, ref = nil, &block)
      @perms[name.to_sym] =
        case ref
        when String
          node = root[*(ref.split('/').select { |p| !p.empty? })]
          raise "missing absolute reference #{ref} in #{self}" unless node
          n = node.dup(name)
          n.instance_eval(&block) if block
          n
        when Symbol
          node = @perms[ref]
          raise "missing relative reference #{ref} in #{self}" unless node
          node.dup(name)
        else
          Permission.new(name, self, &block)
        end
    end

    def method_missing(method, *args, &block)
      if block_given? || args.size == 1
        child(method, args[0], &block)
      else
        @perms[method] || super
      end
    end

    def respond_to?(method, *)
      ! @perms[method].nil? || super
    end

    def to_name
      (@parent ? @parent.to_name : '') + "/#{@name}"
    end

    def to_s
      'Permissions<' + to_name + '>[' + @perms.keys.join(',') + ']'
    end

  end
end
