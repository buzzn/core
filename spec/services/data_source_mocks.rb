class MockRegister < Register::Input

  def data_source; 'mock'; end

end

class ChartsDummyDataSource < Buzzn::DataSource

  NAME = :dummy
  def method_missing(method, *args)
    # this is just an array with an extra expires_at field
    result = [method] + args
    def result.expires_at=(a);end
    result
  end
  def aggregated(resource, mode, interval)
    method_missing(:aggregated, resource, mode, interval) unless resource.is_a? Group::Base
  end

end

class ChartsMockDataSource < Buzzn::DataSource

  NAME = :mock
  attr_accessor :input, :output
  def aggregated(resource, mode, interval)
    mode == 'in' ? @input.shift : @output.shift
  end
  def method_missing(method, *args)
    nil
  end

end
