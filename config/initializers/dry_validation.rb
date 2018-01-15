require 'active_record'
require 'buzzn/schemas/support/enable_dry_validation'

ActiveRecord::Base.send(:include, Schemas::Support::DryValidationForActiveRecord)
