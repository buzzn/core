require 'active_support/concern'

module Beekeeper::ImportWarnings

  extend ActiveSupport::Concern

  def warnings
    @warnings ||= {}
  end

  def add_warning(attribute, data)
    warnings[attribute] = data
  end

end
