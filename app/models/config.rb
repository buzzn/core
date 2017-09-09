# coding: utf-8
module Buzzn
  module Core
    class Config < ActiveRecord::Base
      self.table_name = :configs

      def self.load(clazz)
        params =
          self.where(namespace: clazz.name)
          .select(:key, :value)
          .collect { |e| [e.key.to_sym, e.value.to_f] }
        clazz.new Hash[params]
      end

      def self.store(config)
        namespace = config.class.name
        transaction do 
          config.instance_variables.each do |name|
            value = config.instance_variable_get(name)
            key = name.to_s[1..-1]
            old = where(namespace: namespace, key: key).first
            if old
              old.update(value: value)
            else
              create(namespace: namespace, key: key, value: value)
            end
          end
        end
      end
    end
  end
end
