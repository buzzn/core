class RemoveTermsAcceptedFromContract < ActiveRecord::Migration
  def change
    remove_column :contracts, :terms_accepted, :boolean
  end
end
