# coding: utf-8
require_relative 'number'
module Buzzn
  module Math
    class CubicMeter < Number
    end
    Number.create(CubicMeter, :cubic_meter, 'm³')
  end
end
