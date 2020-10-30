# Adds a last sent field to the documents. This can be used to indicate if
# and when a document has been sent to the customers.
class AddDocumentLastSentDate < ActiveRecord::Migration
  def up
    add_column :documents, :last_sent, :timestamp, null: true
  end

  def down
    remove_column :documents, :last_sent
  end
end