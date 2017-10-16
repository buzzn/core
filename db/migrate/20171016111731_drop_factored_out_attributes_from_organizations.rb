class DropFactoredOutAttributesFromOrganizations < ActiveRecord::Migration
  def change
    %i(edifactemail mode market_place_id).each do |column|
      remove_column :organizations, column, :string
    end
  end
end
