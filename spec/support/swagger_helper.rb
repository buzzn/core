module SwaggerHelper

  def self.included(spec)
    spec.extend(ClassMethods)
    spec.after(:all) do
      # want to sort the paths
      sorted = paths.instance_variable_get(:@paths).sort { |m,n| m <=> n }
      paths.instance_variable_set(:@paths, sorted)
      puts swagger.to_yaml
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
      when ''
        asd
      when 'enum'
        sparam.type = 'string'
        sparam.enum = type[1..-1]
      else
        sparam.type = type[0]
        sparam.format = type[1]
      end
      ops.add_parameter(sparam)
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
        else
          ['enum', rule.options[:args].flatten]
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
          s.info.version = nil
          s.basePath = "/api/#{name.downcase}"
          block.call(s) if block
          s
        end
    end

    def paths
      @paths ||= Swagger::Data::Paths.new
    end

    def post(path)
      self.it path do
        yield self
        POST path, admin, {}
      end
    end
    
    def get(path, &block)
      it path do
        spath = Swagger::Data::Path.new
        ops = spath.get = Swagger::Data::Operation.new
        ops.produces = ['application/json']
        path.scan(/\{[^{}]*\}/).each do |param|
          sparam = Swagger::Data::Parameter.new
          sparam.name = param[1..-2].gsub('.', '_')
          sparam.in = 'path'
          sparam.required = true
          sparam.type = 'string'
          ops.add_parameter(sparam)
        end
        paths.add_path(path.gsub('.', '_'), spath)
        self.current = ops
        real_path = eval "\"#{swagger.basePath}#{path.gsub(/\{/, '#{')}\""
        GET real_path, admin
        expect([200, 201, 422]).to include response.status
        instance_eval &block
        if response.status == 422
          expect_missing(ops)
        end
      end
    end

  end
end
