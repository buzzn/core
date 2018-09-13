module Register
  class MetaOption < ActiveRecord::Base

    self.table_name = :register_meta_options

    has_many :contracts, -> { where(type: %w(Contract::LocalpoolPowerTaker Contract::LocalpoolGap Contract::LocalpoolThirdParty)) }, class_name: 'Contract::Base', foreign_key: :register_meta_option_id

  end
end
