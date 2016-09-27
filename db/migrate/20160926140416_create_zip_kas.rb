class CreateZipKas < ActiveRecord::Migration
  def change
    create_table :zip_kas, id: false do |t|
      t.string :zip
      t.float :ka
    end
    execute "ALTER TABLE zip_kas ADD PRIMARY KEY (zip);"
  end
end
