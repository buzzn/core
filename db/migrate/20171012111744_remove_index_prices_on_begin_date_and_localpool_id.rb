class RemoveIndexPricesOnBeginDateAndLocalpoolId < ActiveRecord::Migration
  def up
    remove_index "prices", name: :index_prices_on_begin_date_and_localpool_id
  end

  def down
    add_index "prices", ["begin_date", "localpool_id"], :name=>"index_prices_on_begin_date_and_localpool_id", :unique=>true, :using=>:btree
  end
end
