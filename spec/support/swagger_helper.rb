module SwaggerHelper

  def self.included(spec)
    spec.extend(ClassMethods)
    spec.after(:all) do
      # want to sort the paths
      sorted = paths.instance_variable_get(:@paths).sort { |m,n| m[0] <=> n[0] }
      paths.instance_variable_set(:@paths, sorted)
      # dump inot yaml file as it tracks diffs better than json
      file = swagger.basePath.sub(/.api/, 'lib/buzzn/roda') + '/swagger.yaml'
      File.write(file, swagger.to_yaml)
      puts "dumped swagger yaml #{file}"
    end
  end

  def admin
    self.class.admin
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

  def schema(key)
    @schema = key
  end

  def expect_missing(ops)
    expect(@schema).not_to be_nil
    schema = Buzzn::Transaction.transactions.steps[@schema]
    expected = []
    schema.rules.each do |name, rule|
      required = rule.is_a? Dry::Logic::Operations::And
      if required
        expected << { 'parameter' => "#{name}", 'detail' => 'is missing' }
      end
      rules = rule.rules[1..-1]
      
      sparam = Swagger::Data::Parameter.new
      sparam.name = name.to_s
      sparam.in = 'formData'
      sparam.required = required
      type = type_predicate(rules)
      case type[0]
      when 'enum'
        sparam.type = 'string'
        sparam.enum = type[1..-1]
      else
        sparam.type = type[0]
        sparam.format = type[1] if type[1]
      end
      ops.add_parameter(sparam)
      ops.consumes = ['application/x-www-form-urlencoded']
    end
    expect(expected).to match_array json['errors']
  end

  def type_predicate(rules)
    rules.collect do |rule|
      case rule
      when Dry::Logic::Operations::And
        type_predicate(rule.rules)
      when Dry::Logic::Operations::Key
        type_predicate(rule.rules)
      when Dry::Logic::Rule::Predicate
        type = rule.predicate.to_s.gsub(/.*#|\?>$/, '')
        case type
        when 'filled'
          [nil, nil]
        when 'int'
          ['integer', 'int64']
        when 'str'
          ['string', '']
        when 'time'
          ['string', 'date-time']
        when 'included_in'
          ['enum', rule.options[:args].flatten]
        when 'max_size'
          [nil, nil] # ignored for the time being
        else
          ['string', rule.to_s.sub('?', '')]
        end
      else
        binding.pry
      end   
    end.compact.flatten.compact
  end

  module ClassMethods

    def admin
      @admin ||= Fabricate(:admin_token)
    end

    def swagger(&block)
      @swagger ||=
        begin
          s = Swagger::Data::Document.new
          s.paths = paths
          name = self.to_s.sub(/.*:/, '')
          s.info.description = "Swagger for #{name} Internal API"
          s.info.title = "#{name} API"
          s.info.version = '1'
          s.basePath = "/api/#{name.downcase}"
          block.call(s) if block
          s
        end
    end

    def paths
      @paths ||= Swagger::Data::Paths.new
    end

    def generic(path, method, &block)
      it "#{method.to_s.upcase} #{path}" do
        normalized = path.gsub(/_[1-9]/, '').gsub('.', '_')
        unless spath = paths[normalized]
          spath = Swagger::Data::Path.new
          paths.add_path(normalized, spath)
        end
        ops = spath.send("#{method}=", Swagger::Data::Operation.new)
        ops.produces = ['application/json']
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
          resp.description = 'created'
          responses.add_response(201, resp)
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
        real_path = eval "\"#{swagger.basePath}#{path.gsub(/\{/, '#{')}\""
        send(method.to_s.upcase, real_path, admin)
        expect([200, 201, 204, 422]).to include response.status
        instance_eval &block
        if [:post, :patch, :put].include?(method) || response.status == 422
          expect_missing(ops)
        end
      end
    end

    [:post, :get, :patch, :delete].each do |method|
      define_method(method) do |path, &block|
        generic(path, method, &block) if path
      end
    end
  end
end
