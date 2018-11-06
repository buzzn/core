class CreateWebsiteForms < ActiveRecord::Migration

  def change
    create_table :website_forms do |t|
      t.string :form_name, null: false, limit: 64
      t.json :form_content
      t.boolean :processed, null: false, default: false
      t.timestamps
    end
    add_index :website_forms, :form_name
  end

end
