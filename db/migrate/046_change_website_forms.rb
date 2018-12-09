class ChangeWebsiteForms < ActiveRecord::Migration

  def change
    change_table :website_forms do |t|
      t.string :comment
    end
  end

end
