require 'ruby-swagger'

module SwaggerHelper

  def self.included(spec)
    spec.extend(ClassMethods)
    spec.after(:all) do
      # want to sort the paths
      sorted = paths.instance_variable_get(:@paths).sort { |m, n| m[0] <=> n[0] }
      paths.instance_variable_set(:@paths, sorted)
      # dump inot yaml file as it tracks diffs better than json
      file = swagger.basePath.sub(/.api/, 'lib/buzzn/roda') + '/swagger.yaml'
      File.write(file, swagger.to_yaml)
      logger = Buzzn::Logger.new(self)
      logger.debug("Dumped swagger yaml #{file}")
    end
  end

  def swagger(&block)
    self.class.swagger(&block)
  end

  def paths
    self.class.paths
  end

  def current=(c)
    @current = c
  end

  def description(text)
    @current.description = text
  end

  def schema(key, expected = nil)
    @schema = key
    @expected = expected
  end

  def expect_missing(ops, consumes, params)
    consumes ||= ['application/x-www-form-urlencoded']
    params ||= {}

    expect(@schema).not_to be_nil
    expected = @expected || {}
    process_rule = ->(name: nil, required: nil, type: nil, options: {}) do
      if required && @expected.nil? && !name&.include?('.')
        expected[name] = ['is missing']
      end

      sparam = Swagger::Data::Parameter.new
      sparam.name = name.to_s
      sparam.in = 'formData'
      sparam.required = required
      case type
      when :string
        sparam.type = 'string'
        sparam.format = options[:format] || ''
        sparam.maxLength = options[:max_size]
        sparam.minLength = options[:min_size]
      when :enum
        sparam.type = 'string'
        sparam.enum = options[:values]
      when :integer
        sparam.type = 'integer'
        sparam.format = 'int64'
        sparam.maximum = options[:max] if options[:max]
        sparam.exclusiveMaximum = options[:exclusive_max] if options[:exclusive_max]
        sparam.minimum = options[:min] if options[:min]
        sparam.exclusiveMinimum = options[:exclusive_min] if options[:exclusive_min]
      when :bigint
        sparam.type = 'integer'
        sparam.format = 'int64'
        sparam.maximum = options[:max] if options[:max]
        sparam.exclusiveMaximum = options[:exclusive_max] if options[:exclusive_max]
        sparam.minimum = options[:min] if options[:min]
        sparam.exclusiveMinimum = options[:exclusive_min] if options[:exclusive_min]
      when :date
        sparam.type = 'string'
        sparam.format = 'date'
      when :datetime
        sparam.type = 'string'
        sparam.format = 'date-time'
      when :date_time
        sparam.type = 'string'
        sparam.format = 'date-time'
      when :float
        sparam.type = 'number'
        sparam.format = 'float'
        sparam.maximum = options[:max] if options[:max]
        sparam.exclusiveMaximum = options[:exclusive_max] if options[:exclusive_max]
        sparam.minimum = options[:min] if options[:min]
        sparam.exclusiveMinimum = options[:exclusive_min] if options[:exclusive_min]
      when :boolean
        sparam.type = 'boolean'
      when :hash
        sparam.type = 'hash'
      when :array
        sparam.type = 'array'
      else
        sparam.type = 'string'
        sparam.format = type.to_s
      end
      ops.add_parameter(sparam)
      ops.consumes = consumes
    end

    params_process = ->(prefix: '', p: {}) do
      p.each do |k, v|
        name = k.to_s
        unless prefix.blank?
          name = prefix + '.' + name
        end
        if v.is_a? Hash
          params_process.call(prefix: name, p: v)
        elsif v.blank?
          process_rule.call(name: name, required: true, type: nil, options: { })
        elsif v == 'dontinclude'
          next
        else
          process_rule.call(name: name, required: true, type: :enum, options: { values: [v] })
        end
      end
    end

    unless params.blank?
      params_process.call(p: params)
    end

    Schemas::Support::Visitor.visit(@schema, &process_rule)
    expect(expected).to eq json unless expected.blank? || !params.blank?
  end

  module ClassMethods

    def swagger(&block)
      @swagger ||=
        begin
          s = Swagger::Data::Document.new
          s.paths = paths
          name = self.to_s.sub(/.*:/, '')
          s.info.description = "Swagger for #{name} Internal API"
          s.info.title = "#{name} API"
          s.info.version = '1'
          block.call(s) if block
          s.basePath = "/api/#{name.downcase}"
          s
        end
    end

    def paths
      @paths ||= Swagger::Data::Paths.new
    end

    def generic(path, method, user, options, params, &block)
      it "#{method.to_s.upcase} #{path}" do
        user ||= $admin
        normalized = path.gsub(/_[1-9]/, '').gsub('.', '_')
        unless spath = paths[normalized]
          spath = Swagger::Data::Path.new
          paths.add_path(normalized, spath)
        end
        ops = spath.send("#{method}=", Swagger::Data::Operation.new)
        ops.produces = options[:produces].nil? ? ['application/json'] : options[:produces]
        path.scan(/\{[^{}]*\}/).each do |param|
          sparam = Swagger::Data::Parameter.new
          sparam.name = param[1..-2].sub(/_[1-9]/, '').gsub('.', '_')
          sparam.in = 'path'
          sparam.required = true
          sparam.type = 'string'
          ops.add_parameter(sparam)
        end

        responses = Swagger::Data::Responses.new
        resp = Swagger::Data::Response.new
        case method
        when :get
          resp.description = 'success'
          responses.add_response(200, resp)
        when :post
          resp.description = options[:description] || 'created'
          responses.add_response(options[:status] || 201, resp)
        when :patch
          resp.description = 'patched'
          responses.add_response(200, resp)
        when :delete
          resp.description = 'deleted'
          responses.add_response(204, resp)
        else
          raise "unknown method #{method}"
        end
        ops.responses = responses
        self.current = ops
        real_path = eval "\"#{swagger.basePath}#{path.gsub(/\{/, '#{').sub(/\/$/, '')}\""
        send(method.to_s.upcase, real_path, user, params)
        expect([200, 201, 204, 422, 401, 403]).to include response.status
        instance_eval &block
        if [:post, :patch, :put].include?(method) || response.status == 422
          expect_missing(ops, options[:consumes], params)
        end
      end
    end

    [:post, :get, :patch, :delete].each do |method|
      define_method(method) do |path, user = nil, options = {}, params = {}, &block|
        generic(path, method, user, options, params, &block) if path
      end
    end

  end

end
