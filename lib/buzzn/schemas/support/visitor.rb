require_relative '../support'

class Schemas::Support::Visitor

  def self.visit(schema, &block)
    new.visit(schema, &block)
  end

  def visit(schema, prefix = '', &block)
    schema.rules.each do |name, rule|
      required =
        case rule
        when Dry::Logic::Operations::And
          true
        when Dry::Logic::Operations::Implication
          false
        else
          raise "do not know what to do with #{rule.class}"
        end
      result = visit_rule(rule.rules[1..-1], {}, name, &block)
      block.call(name: "#{prefix}#{name}", required: required, type: result.delete(:type), options: result) if result
    end
  end

  def visit_rule(rules, result, name = nil, &block)
    rules.collect do |rule|
      case rule
      when Dry::Logic::Operations::And
        visit_rule(rule.rules, result, name, &block)
      when Dry::Logic::Operations::Key
        visit_rule(rule.rules, result, name, &block)
      when Dry::Logic::Operations::Implication
        visit_rule(rule.rules[1..-1], result, name, &block)
      when Dry::Logic::Rule::Predicate
        type = rule.predicate.to_s.gsub(/.*#|\?>$/, '')
        case type
        when 'filled'
          nil # nothing to do here
        when 'bool'
          result[:type] = :boolean
        when 'int'
          result[:type] = :integer
        when 'str'
          result[:type] = :string
        when 'time'
          result[:type] = :datetime
        when 'format'
          result[:format] = rule.options[:args].first
        when 'included_in'
          result[:type] = :enum
          result[:values] = rule.options[:args].flatten
        when 'size'
          result[:max_size] = result[:min_size] = rule.options[:args].first
        when 'max_size'
          result[:max_size] = rule.options[:args].first
        when 'min_size'
          result[:min_size] = rule.options[:args].first
        when 'gteq'
          result[:min] = rule.options[:args].first
          result[:exclusive_min] = false
        when 'gt'
          result[:min] = rule.options[:args].first
          result[:exclusive_min] = true
        when 'lteq'
          result[:max] = rule.options[:args].first
          result[:exclusive_max] = false
        when 'lt'
          result[:max] = rule.options[:args].first
          result[:exclusive_max] = true
        else
          result[:type] = rule.to_s.sub('?', '').to_sym unless result[:type]
        end
      when Dry::Validation::Schema
        visit(rule, "#{name}.", &block)
        result = nil
      else
        raise "do not know what to do with #{rule.class}"
      end
    end
    result
  end

end
