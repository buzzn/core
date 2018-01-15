require_relative '../services'
require 'leafy/core/metric_registry'

Services::Metrics = Leafy::Core::MetricRegistry
