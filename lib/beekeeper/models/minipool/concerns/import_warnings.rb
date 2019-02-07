require 'active_support/concern'

module Beekeeper::ImportWarnings

  mattr_accessor :logger

  extend ActiveSupport::Concern

  def add_warning(attribute, data)
    logger.warn(attribute, extra_data: data)
  end

end
