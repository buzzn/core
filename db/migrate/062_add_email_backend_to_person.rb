# Adds MailBackend informationt to a person.
class AddEmailBackendToPerson < ActiveRecord::Migration

  def up
    add_column :persons, :email_backend_host, :string, :limit => 128
    add_column :persons, :email_backend_port, :int
    add_column :persons, :email_backend_user, :string, :limit => 128
    add_column :persons, :email_backend_password, :string, :limit => 128
    add_column :persons, :email_backend_encryption, :string, :limit => 16
    add_column :persons, :email_backend_active, :boolean, :default => false
    add_column :persons, :email_backend_signature, :string
  end

  def down
    remove_column :persons, :email_backend_host
    remove_column :persons, :email_backend_port
    remove_column :persons, :email_backend_user
    remove_column :persons, :email_backend_password
    remove_column :persons, :email_backend_encryption
    remove_column :persons, :email_backend_active
    remove_column :persons, :email_backend_signature
  end

end
