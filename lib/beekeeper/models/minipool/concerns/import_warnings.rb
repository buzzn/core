require 'active_support/concern'

module Beekeeper::ImportWarnings

  extend ActiveSupport::Concern

  # A hash of all information that we want to show to PhO about imported attributes -- questions, fixes, etc.
  def warnings
    @warnings ||= {}
  end

  def add_warning(attribute, data)
    warnings[attribute] = data
  end
end
