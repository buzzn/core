require 'multi_json'
unless defined? JRUBY_VERSION
  # just make sure we use OJ
  MultiJson.engine= :oj
end
