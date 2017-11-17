require 'buzzn/schemas/support/enable_dry_validation'

ActiveRecord::Base.send(:include, Buzzn::Schemas::DryValidationForActiveRecord)
