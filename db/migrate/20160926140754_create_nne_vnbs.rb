class CreateNneVnbs < ActiveRecord::Migration
  def change
    create_table :nne_vnbs, id: false do |t|
      t.string :verbandsnummer, null: false
      t.string :typ
      t.float :messung_et
      t.float :abrechnung_et
      t.float :zaehler_et
      t.float :mp_et
      t.float :messung_dt
      t.float :abrechnung_dt
      t.float :zaehler_dt
      t.float :mp_dt
      t.float :arbeitspreis
      t.float :grundpreis
      t.boolean :vorlaeufig
    end
    add_index :nne_vnbs, :verbandsnummer, unique: true
  end
end
