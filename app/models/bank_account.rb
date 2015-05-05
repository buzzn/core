class BankAccount < ActiveRecord::Base
  include Authority::Abilities
  belongs_to :bank_accountable, polymorphic: true


  validates_with IbanValidator

  attr_encrypted :iban, :charset => 'UTF-8', :key => Rails.application.secrets.attr_encrypted_key

  validates :holder,        presence: true
  validates :iban,          presence: true


end
